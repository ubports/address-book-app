/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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

#ifndef _UBUNTU_CONTACTS_H_
#define _UBUNTU_CONTACTS_H_

#include <QtCore/QObject>
#include <QtCore/QString>

class UbuntuContacts : public QObject
{
    Q_OBJECT

public:
    UbuntuContacts(QObject *parent = 0);

    Q_INVOKABLE QString contactInitialsFromString(const QString &value);
    Q_INVOKABLE QString normalized(const QString &value);
};

#endif //_UBUNTU_CONTACTS_H_
