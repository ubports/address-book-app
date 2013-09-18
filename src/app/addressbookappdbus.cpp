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

#include "addressbookappdbus.h"
#include "addressbookappadaptor.h"

// Qt
#include <QtDBus/QDBusConnection>

AddressBookAppDBus::AddressBookAppDBus(QObject* parent) : QObject(parent)
{
}

AddressBookAppDBus::~AddressBookAppDBus()
{
}

QString AddressBookAppDBus::serviceName()
{
    return "com.canonical.AddressBookApp";
}

QString AddressBookAppDBus::objectPath()
{
    return "/com/canonical/AddressBookApp";
}

QString AddressBookAppDBus::interfaceName()
{
    return "com.canonical.AddressBookApp";
}

bool
AddressBookAppDBus::connectToBus()
{
    bool ok = QDBusConnection::sessionBus().registerService(serviceName());
    if (!ok) {
        return false;
    }
    new AddressBookAppAdaptor(this);
    QDBusConnection::sessionBus().registerObject(objectPath(), this);

    return true;
}

void AddressBookAppDBus::ShowContact(const QVariant &contactId)
{
    Q_EMIT request(QString("contact://%1").arg(contactId.toString()));
}

void AddressBookAppDBus::CreateContact(const QString &phoneNumber)
{
    Q_EMIT request(QString("create://%1").arg(phoneNumber));
}

void AddressBookAppDBus::SendAppMessage(const QString &message)
{
    qDebug() << "DBUS CALLL" << message;
    Q_EMIT request(message);
}

void AddressBookAppDBus::AddPhoneToContact(const QString &contactId, const QString &phoneNumber)
{
    Q_EMIT request(QString("addressbook://edit?%1&%2").arg(contactId).arg(phoneNumber));
}

