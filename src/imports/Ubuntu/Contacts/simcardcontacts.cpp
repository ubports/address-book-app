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
    m_modemsChangedTimer.setInterval(1000);
    m_modemsChangedTimer.setSingleShot(true);
    connect(m_ofonoManager.data(),
            SIGNAL(modemsChanged(QStringList)),
            SLOT(onManagerChanged()),
            Qt::QueuedConnection);
    connect(m_ofonoManager.data(),
            SIGNAL(availableChanged(bool)),
            SLOT(onManagerChanged()),
            Qt::QueuedConnection);
    connect(&m_modemsChangedTimer,
            SIGNAL(timeout()),
            SLOT(onModemsChanged()));
}

SimCardContacts::~SimCardContacts()
{
    Q_FOREACH(QOfonoModem *m, m_availableModems) {
        disconnect(m);
        m->deleteLater();
    }
    m_availableModems.clear();

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

bool SimCardContacts::busy() const
{
    return (m_modemsChangedTimer.isActive() ||
            m_importingFlag);
}

void SimCardContacts::unlockModem(const QString &modemPath)
{
    static const QString connService("com.ubuntu.connectivity1");
    static const QString connObject("/com/ubuntu/connectivity1/Private");
    static const QString connInterface("com.ubuntu.connectivity1.Private");
    static const QString connUnlockmodemMethod("UnlockModem");

    QDBusInterface connectivityIface (connService,
                                      connObject,
                                      connInterface,
                                      QDBusConnection::sessionBus(),
                                      this);

    auto reply = connectivityIface.call(connUnlockmodemMethod, modemPath);
    if (reply.type() == QDBusMessage::ErrorMessage) {
        qWarning() << "Failed to unlock modem" << modemPath << reply.errorMessage();
    }
}

void SimCardContacts::onPhoneBookIsValidChanged(bool isValid)
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);
    if (isValid) {
        importPhoneBook(pb);
    } else {
        m_pendingPhoneBooks.remove(pb);
        if (m_pendingPhoneBooks.isEmpty()) {
            importDone();
        }
        pb->deleteLater();
    }
}

void SimCardContacts::onModemsChanged()
{
    qDebug() << "Modems changed";
    startImport();

    Q_FOREACH(QOfonoModem *modem, m_availableModems) {
        importPhoneBook(modem);
    }

    if (m_pendingPhoneBooks.size() == 0) {
        importDone();
    }
}

void SimCardContacts::onManagerChanged()
{
    startImport();

    // clear modem list
    Q_FOREACH(QObject *m, m_availableModems) {
        disconnect(m);
        m->deleteLater();
    }
    m_availableModems.clear();

    if (!m_ofonoManager->available()) {
        qWarning() << "Manager not available;";
        return;
    }

    QStringList modems = m_ofonoManager->modems();
    Q_FOREACH(const QString &modem, modems) {
        QOfonoModem *m = new QOfonoModem(this);

        m->setModemPath(modem);
        m_availableModems << m;

        importPhoneBook(m);

        connect(m, SIGNAL(interfacesChanged(QStringList)),
                &m_modemsChangedTimer, SLOT(start()));
        connect(m, SIGNAL(validChanged(bool)),
                &m_modemsChangedTimer, SLOT(start()));
    }

    if (m_pendingPhoneBooks.size() == 0) {
        importDone();
    }
}

bool SimCardContacts::importPhoneBook(QOfonoModem *modem)
{
    if (hasPhoneBook(modem)) {
        QOfonoPhonebook *pb = new QOfonoPhonebook(this);
        pb->setModemPath(modem->modemPath());
        m_pendingPhoneBooks << pb;
        if (pb->isValid()) {
            importPhoneBook(pb);
        } else {
            connect(pb,
                    SIGNAL(validChanged(bool)),
                    SLOT(onPhoneBookIsValidChanged(bool)),
                    Qt::QueuedConnection);
        }
        return true;
    } else {
        qDebug() << "Modem" << modem->modemPath() << "does not have phonebook interface";
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

    if (!vcardData.trimmed().isEmpty()) {
        m_vcards << vcardData;
    }
    m_pendingPhoneBooks.remove(pb);
    if (m_pendingPhoneBooks.isEmpty()) {
        importDone();
    }
    pb->deleteLater();
}

void SimCardContacts::onPhoneBookImportFail()
{
    QOfonoPhonebook *pb = qobject_cast<QOfonoPhonebook*>(QObject::sender());
    Q_ASSERT(pb);
    qWarning() << "Fail to import contacts from:" << pb->modemPath();

    m_pendingPhoneBooks.remove(pb);
    if (m_pendingPhoneBooks.isEmpty()) {
        importDone();
    }
    pb->deleteLater();
    Q_EMIT importFail();
}

void SimCardContacts::startImport()
{
    m_importingFlag = true;
    Q_EMIT busyChanged();
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
}

void SimCardContacts::importDone()
{
    Q_ASSERT(m_pendingModems.isEmpty());

    writeData();
    m_importing.unlock();
    Q_EMIT contactsChanged();
    m_importingFlag = false;
    Q_EMIT busyChanged();
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
    Q_FOREACH(QOfonoPhonebook *m, m_pendingPhoneBooks) {
        disconnect(m);
        m->deleteLater();
    }
    m_pendingPhoneBooks.clear();

    m_importing.unlock();
    m_vcards.clear();

    m_importingFlag = false;
    Q_EMIT busyChanged();
}

bool SimCardContacts::hasPhoneBook(QOfonoModem *modem)
{
    return (modem->isValid() && modem->interfaces().contains("org.ofono.Phonebook"));
}
