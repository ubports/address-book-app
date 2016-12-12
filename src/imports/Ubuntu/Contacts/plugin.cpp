/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
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

#include "plugin.h"
#include "contacts.h"
#include "simcardcontacts.h"

#include <QQmlEngine>
#include <qqml.h>

static QObject *contactsProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return new UbuntuContacts;
}

void UbuntuContactsPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(engine);
    Q_UNUSED(uri);
}

void UbuntuContactsPlugin::registerTypes(const char *uri)
{
    // @uri Ubuntu.Contacts
    qmlRegisterSingletonType<UbuntuContacts>(uri, 0, 1, "Contacts", contactsProvider);
    qmlRegisterType<SimCardContacts>(uri, 0, 1, "SimCardContacts");
}
