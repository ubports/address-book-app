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

#include "contacts.h"

#include <QtCore/QStringList>
#include <QtCore/QDebug>

UbuntuContacts::UbuntuContacts(QObject *parent)
    : QObject(parent)
{
}

QString UbuntuContacts::contactInitialsFromString(const QString &value)
{
    if (value.isEmpty() || !value.at(0).isLetter()) {
        return QString();
    }

    QString initials;
    QStringList parts = value.split(" ");
    initials = parts.first().at(0).toUpper();
    if (parts.size() > 1) {
        initials += parts.last().at(0).toUpper();
    }

    return initials;
}
