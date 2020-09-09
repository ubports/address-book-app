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

#ifndef SIMCARDCONTACTS_H
#define SIMCARDCONTACTS_H

#include <QObject>
#include <QMutex>

#include <qofonomanager.h>
#include <qofonophonebook.h>
#include <qofonomodem.h>

class SimCardContacts : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString contacts READ contacts NOTIFY contactsChanged)
    Q_PROPERTY(QUrl vcardFile READ vcardFile NOTIFY contactsChanged)
    Q_PROPERTY(bool hasContacts READ hasContacts NOTIFY contactsChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:
    SimCardContacts(QObject *parent=0);
    ~SimCardContacts();

    QString contacts() const;
    QUrl vcardFile() const;
    bool hasContacts() const;
    bool busy() const;

    Q_INVOKABLE void unlockModem(const QString &modemPath);

Q_SIGNALS:
    void contactsChanged();
    void importFail();
    void busyChanged();

private Q_SLOTS:
    void onPhoneBookIsValidChanged(bool isValid);
    void onPhoneBookImported(const QString &vcardData);
    void onPhoneBookImportFail();
    void onManagerChanged();
    void onModemsChanged();
    void reload();

private:
    QScopedPointer<QOfonoManager> m_ofonoManager;
    QSet<QOfonoPhonebook*> m_pendingPhoneBooks;
    QSet<QOfonoModem*> m_availableModems;
    QTemporaryFile *m_dataFile;
    QStringList m_vcards;
    QMutex m_importing;
    QTimer m_modemsChangedTimer;
    bool m_importingFlag;

    bool hasPhoneBook(QOfonoModem *modem);
    void writeData();
    void reloadContactsFromModem(QOfonoModem* modem);
    void cancel();
    void startImport();
    void importDone();
    bool importPhoneBook(QOfonoModem *modem);
    void importPhoneBook(QOfonoPhonebook *phoneBook);
};

#endif
