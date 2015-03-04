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
    onManagerChanged();
    connect(m_ofonoManager.data(),
            SIGNAL(modemsChanged(QStringList)),
            SLOT(onManagerChanged()),
            Qt::QueuedConnection);
    connect(m_ofonoManager.data(),
            SIGNAL(availableChanged(bool)),
            SLOT(onManagerChanged()),
            Qt::QueuedConnection);
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

bool SimCardContacts::hasContacts() const
{
    return !m_vcards.isEmpty();
}

void SimCardContacts::onPhoneBookIsValidChanged(bool isValid)
{
    qDebug() << "Phone book is valid" << isValid;

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

void SimCardContacts::onModemsChanged()
{
    qDebug() << "Modem changed";
    if (!m_importing.tryLock()) {
        qDebug() << "Import in progress.";
        cancel();
        if (!m_importing.tryLock()) {
            qWarning() << "Fail to cancel current import";
            return;
        }
    }
    m_vcards.clear();
    Q_EMIT contactsChanged();

    Q_FOREACH(QOfonoModem *modem, m_availableModems) {
        importPhoneBook(modem);
    }

    if (m_pendingModems.size() == 0) {
        importDone();
    }
}

void SimCardContacts::onManagerChanged()
{
    qDebug() << "Manager Changed";

    Q_FOREACH(QObject *m, m_availableModems) {
        disconnect(m);
        m->deleteLater();
    }
    m_availableModems.clear();

    if (!m_ofonoManager->available()) {
        qDebug() << "Manager not available;";
        return;
    }

    QStringList modems = m_ofonoManager->modems();
    qDebug() << "List contact from" << modems;

    Q_FOREACH(const QString &modem, modems) {
        QOfonoModem *m = new QOfonoModem(this);

        m->setModemPath(modem);
        m_availableModems << m;

        importPhoneBook(m);

        connect(m, SIGNAL(interfacesChanged(QStringList)),
                SLOT(onModemsChanged()),
                Qt::QueuedConnection);
        connect(m, SIGNAL(validChanged(bool)),
                SLOT(onModemsChanged()),
                Qt::QueuedConnection);
    }
}

bool SimCardContacts::importPhoneBook(QOfonoModem *modem)
{
    if (hasPhoneBook(modem)) {
        QOfonoPhonebook *pb = new QOfonoPhonebook(this);
        pb->setModemPath(modem->modemPath());
        m_pendingModems << pb;
        if (pb->isValid()) {
            importPhoneBook(pb);
        } else {
            qDebug() << "Wait for phonebook became valid";
            connect(pb,
                    SIGNAL(validChanged(bool)),
                    SLOT(onPhoneBookIsValidChanged(bool)),
                    Qt::QueuedConnection);
        }
        return true;
    } else {
        qDebug() << "Modem" << modem->modemPath() << "does not have phonebook";
    }
    return false;
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

void SimCardContacts::importDone()
{
    qDebug() << "Import done";
    Q_ASSERT(m_pendingModems.isEmpty());

    writeData();
    m_importing.unlock();
    Q_EMIT contactsChanged();
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

void SimCardContacts::cancel()
{
    Q_FOREACH(QObject *m, m_pendingModems) {
        disconnect(m);
        m->deleteLater();
    }
    m_pendingModems.clear();
    m_importing.unlock();
    m_vcards.clear();
}

bool SimCardContacts::hasPhoneBook(QOfonoModem *modem)
{
    return (modem->isValid() && modem->interfaces().contains("org.ofono.Phonebook"));
}
