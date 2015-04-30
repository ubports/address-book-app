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

import QtQuick 2.2
import QtContacts 5.0

import Ubuntu.Components 1.1

import Ubuntu.AddressBook.ContactEditor 0.1

ContactEditorPage {
    id: root

    head.backAction: Action {
        objectName: "cancel"

        text: i18n.tr("Cancel")
        iconName: "back"
        onTriggered: {
            root.cancel()
            root.active = false
        }
    }

    head.actions: [
        Action {
            objectName: "save"

            text: i18n.tr("Save")
            iconName: "ok"
            // disable save button while avatar scale still running
            enabled: root.isContactValid
            onTriggered: root.save()
        }
    ]

    onContactSaved: {
        if (pageStack.contactListPage) {
            pageStack.contactListPage.moveListToContact(contact)
        }
    }

}
