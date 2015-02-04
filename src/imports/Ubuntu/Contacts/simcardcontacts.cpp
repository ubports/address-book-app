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
        qDebug() << "VCARD FILE NAME" << m_dataFile->fileName();
        return QUrl::fromLocalFile(m_dataFile->fileName());
    } else {
        return QUrl();
    }
}

void SimCardContacts::onModemChanged()
{
    qDebug() << "Modem changed" << m_ofonoManager->modems();
    reloadContacts();
}

void SimCardContacts::onPhoneBookImported(const QString &vcardData)
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);

    if (!m_pendingModems.removeOne(pb)) {
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
    qDebug() << "Fail to import contacts from:" << pb->modemPath();

    if (!m_pendingModems.removeOne(pb)) {
        qWarning() << "fail to remove modem from pending modems;";
    }

    if (m_pendingModems.isEmpty()) {
        importDone();
    }
    pb->deleteLater();
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
        qDebug() << "FILE WRITE ON" << m_dataFile->fileName();
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
    qDebug() << "IMPORTING" << modems;
    m_vcards.clear();

    int modemsCount = 0;
    Q_FOREACH(const QString &modem, modems) {
        QOfonoPhonebook *pb = new QOfonoPhonebook(this);
        m_pendingModems << pb;
        pb->setModemPath(modem);

        if (!pb->isValid()) {
            qDebug() << "MODEM INVALID:" << pb->modemPath() << modem;
        } else {
            qDebug() << "MODEM IS VALID" << pb->modemPath() << modem;
            modemsCount++;
            qDebug() << pb->modemPath() << pb->importing();
            connect(pb,
                    SIGNAL(importReady(QString)),
                    SLOT(onPhoneBookImported(QString)));
            connect(pb,
                    SIGNAL(importFailed()),
                    SLOT(onPhoneBookImportFail()));
            pb->beginImport();
        }
    }

    if (modemsCount == 0) {
        importDone();
    }
}

void SimCardContacts::cancel()
{
    Q_FOREACH(QOfonoPhonebook *pb, m_pendingModems) {
        pb->disconnect(pb);
        pb->deleteLater();
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
