/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "simcardcontacts.h"

#include <QDebug>
#include <QDBusConnection>
#include <qofonophonebook.h>
#include <qofono-qt5/dbus/ofonophonebook.h>

SimCardContacts::SimCardContacts(QObject *parent)
    : QObject(parent),
      m_ofonoManager(new QOfonoManager(this)),
      m_dataFile(0)
{
    reloadContacts();
    connect(m_ofonoManager.data(),
            SIGNAL(modemsChanged(QStringList)),
            SLOT(onModemChanged()));
    connect(m_ofonoManager.data(),
            SIGNAL(availableChanged(bool)),
            SLOT(onModemChanged()));
}

SimCardContacts::~SimCardContacts()
{
    cancel();
    delete m_dataFile;
}

QString SimCardContacts::contacts() const
{
    QString result;
    Q_FOREACH(const QString &data, m_vcards) {
        result += data;
    }
    return result;
}

QUrl SimCardContacts::vcardFile() const
{
    if (m_dataFile) {
        return QUrl::fromLocalFile(m_dataFile->fileName());
    } else {
        return QUrl();
    }
}

void SimCardContacts::onModemChanged()
{
    reloadContacts();
}

void SimCardContacts::onPhoneBookImported(const QString &vcardData)
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);

    if (!m_pendingModems.remove(pb)) {
        qWarning() << "fail to remove modem from pending modems;";
    }

    m_vcards << vcardData;
    if (m_pendingModems.isEmpty()) {
        importDone();
    }
    pb->deleteLater();
}

void SimCardContacts::onPhoneBookImportFail()
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);
    qWarning() << "Fail to import contacts from:" << pb->modemPath();

    m_pendingModems.remove(pb);
    if (m_pendingModems.isEmpty()) {
        importDone();
    }
    pb->deleteLater();
}

void SimCardContacts::onModemIsValidChanged(bool isValid)
{
    QOfonoModem *m = qobject_cast<QOfonoModem*>(QObject::sender());

    Q_ASSERT(m);
    m_pendingModems.remove(m);
    if (isValid) {
        importPhoneBook(m);
    } else {
        m->deleteLater();
    }
    if (m_pendingModems.isEmpty()) {
        importDone();
    }
}

void SimCardContacts::onPhoneBookIsValidChanged(bool isValid)
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);
    if (isValid) {
        importPhoneBook(pb);
    } else {
        m_pendingModems.remove(pb);
        pb->deleteLater();
        if (m_pendingModems.isEmpty()) {
            importDone();
        }
    }
}

void SimCardContacts::writeData()
{
    if (m_dataFile) {
        delete m_dataFile;
        m_dataFile = 0;
    }
    if (!m_vcards.isEmpty()) {
        m_dataFile = new QTemporaryFile();
        m_dataFile->open();
        Q_FOREACH(const QString &data, m_vcards) {
            m_dataFile->write(data.toUtf8());
        }
        m_dataFile->close();
    }
}

void SimCardContacts::reloadContacts()
{
    if (!m_ofonoManager->available()) {
        qDebug() << "Manager not available;";
        return;
    }

    if (!m_importing.tryLock()) {
        qWarning() << "Imort from sim card in progress.";
        cancel();
        if (!m_importing.tryLock()) {
            qWarning() << "Fail to cancel current import operation.";
            return;
        }
    }
    QStringList modems = m_ofonoManager->modems();
    m_vcards.clear();

    Q_FOREACH(const QString &modem, modems) {
        QOfonoModem *m = new QOfonoModem(this);
        m->setModemPath(modem);

        if (m->isValid()) {
            importPhoneBook(m);
        } else {
            // wait for moem interfaces bacame available
            m_pendingModems << m;
            connect(m,
                    SIGNAL(validChanged(bool)),
                    SLOT(onModemIsValidChanged(bool)));
        }
    }
    if (m_pendingModems.isEmpty()) {
        importDone();
    }
}

void SimCardContacts::importPhoneBook(QOfonoModem *modem)
{
     if (modem->interfaces().contains("org.ofono.Phonebook")) {
        QOfonoPhonebook *pb = new QOfonoPhonebook(this);
        pb->setModemPath(modem->modemPath());
        m_pendingModems << pb;
        if (!pb->isValid()) {
            connect(pb,
                    SIGNAL(validChanged(bool)),
                    SLOT(onPhoneBookIsValidChanged(bool)));
        } else {
            importPhoneBook(pb);
        }
    }
     modem->deleteLater();
}

void SimCardContacts::importPhoneBook(QOfonoPhonebook *phoneBook)
{
    connect(phoneBook,
            SIGNAL(importReady(QString)),
            SLOT(onPhoneBookImported(QString)));
    connect(phoneBook,
            SIGNAL(importFailed()),
            SLOT(onPhoneBookImportFail()));

    phoneBook->beginImport();
}

void SimCardContacts::cancel()
{
    Q_FOREACH(QObject *m, m_pendingModems) {
        disconnect(m);
        m->deleteLater();
    }
    m_pendingModems.clear();
    m_importing.unlock();
}

void SimCardContacts::importDone()
{
    writeData();
    m_importing.unlock();
    Q_EMIT contactsChanged();
}
