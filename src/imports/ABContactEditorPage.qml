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

import QtQuick 2.4
import QtContacts 5.0

import Ubuntu.Components 1.3

import Ubuntu.AddressBook.ContactEditor 0.1

ContactEditorPage {
    id: root
    objectName: "contactEditorPage"

    property alias backIconName: backAction.iconName

    // Property used on unit tests
    readonly property alias saveActionEnabled: saveAction.enabled

    head.backAction: Action {
        id: backAction

        objectName: "cancel"
        name: "cancel"

        text: i18n.tr("Cancel")
        iconName: "back"
        // WORKAROUND: SDK does not unregister shortcut on object destruction
        // we need to do it manually. (bug #1518420)
        enabled: root.active && root.enabled
        shortcut: enabled ? "Esc" : undefined
        onTriggered: root.cancel()
    }

    head.actions: [
        Action {
            id: saveAction
            objectName: "save"
            name: "save"

            text: i18n.tr("Save")
            iconName: "ok"
            // WORKAROUND: SDK does not unregister shortcut on object destruction
            // we need to do it manually. (bug #1518420)
            enabled: root.isContactValid && root.active
            shortcut: enabled ? "Ctrl+s" : undefined
            onTriggered: root.save()
        }
    ]

    onContactSaved: {
        if (pageStack.contactListPage) {
            pageStack.contactListPage.moveListToContact(contact)
        }
    }
}
