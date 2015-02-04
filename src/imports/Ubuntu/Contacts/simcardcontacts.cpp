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
#include <qofonophonebook.h>

SimCardContacts::SimCardContacts(QObject *parent)
    : QObject(parent),
      m_ofonoManager(new QOfonoManager(this)),
      m_dataFile(0)
{
    reloadContacts();
    connect(m_ofonoManager.data(),
            SIGNAL(modemsChanged(QStringList)),
            SLOT(onModemChanged(QStringList)));
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

void SimCardContacts::onModemChanged(const QStringList &modems)
{
    reloadContacts();
}

void SimCardContacts::onPhoneBookImported(const QString &vcardData)
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);

    if (!m_pendingModems.removeOne(pb)) {
        return;
    }

    m_vcards << vcardData;
    if (m_pendingModems.isEmpty()) {
        writeData();
        m_importing.unlock();
        Q_EMIT contactsChanged();
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
    }
}

void SimCardContacts::reloadContacts()
{
    if (!m_importing.tryLock()) {
        qWarning() << "Imort from sim card in progress.";
        cancel();
        if (!m_importing.tryLock()) {
            qWarning() << "Fail to cancel current import operation.";
            return;
        }
    }
    m_vcards.clear();

    Q_FOREACH(const QString &modem, m_ofonoManager->modems()) {
        QOfonoPhonebook *pb = new QOfonoPhonebook(this);
        m_pendingModems << pb;
        connect(pb,
                SIGNAL(importReady(QString)),
                SLOT(onPhoneBookImported(QString)));
        pb->setModemPath(modem);
        pb->beginImport();
    }
}

void SimCardContacts::cancel()
{
    Q_FOREACH(QOfonoPhonebook *pb, m_pendingModems) {
        pb->deleteLater();
    }
    m_pendingModems.clear();
    m_importing.unlock();
}
