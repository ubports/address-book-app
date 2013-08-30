/*
 * Copyright (C) 2012-2013 Canonical, Ltd.
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

#ifndef ADDRESSBOOK_APPDBUS_H
#define ADDRESSBOOK_APPDBUS_H

#include <QtCore/QObject>
#include <QtDBus/QDBusContext>

/**
 * DBus interface for the phone app
 */
class AddressBookAppDBus : public QObject, protected QDBusContext
{
    Q_OBJECT

public:
    AddressBookAppDBus(QObject* parent=0);
    ~AddressBookAppDBus();

    bool connectToBus();

    static QString serviceName();
    static QString objectPath();
    static QString interfaceName();

public Q_SLOTS:
    Q_NOREPLY void ShowContact(const QVariant &contactId);
    Q_NOREPLY void CreateContact(const QString &phoneNumber);
    Q_NOREPLY void SendAppMessage(const QString &message);

Q_SIGNALS:
    void request(const QString &message);
};

#endif // ADDRESSBOOK_APPDBUS_H
