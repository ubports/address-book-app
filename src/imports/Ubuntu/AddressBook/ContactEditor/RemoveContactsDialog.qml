/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
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

import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import Ubuntu.AddressBook.Base 0.1

RemoveContactsDialog {
    id: removeContactsDialogMessage

    property bool popPages: false
    property var contactEditor

    onCanceled: {
        PopupUtils.close(removeContactsDialogMessage)
    }

    onAccepted: {
        popPages = true
        removeContacts(contactEditor.model)
        PopupUtils.close(removeContactsDialogMessage)
    }

    // hide virtual keyboard if necessary
    Component.onCompleted: {
        contactEditor.enabled = false
        Qt.inputMethod.hide()
    }

    // WORKAROUND: SDK element crash if pop the page where the dialog was created
    Component.onDestruction: {
        contactEditor.enabled = true
        if (popPages) {
            if (contactEditor.pageStack.removePages) {
                contactEditor.pageStack.removePages(contactEditor)
            } else {
                contactEditor.pageStack.pop() // editor page
                contactEditor.pageStack.pop() // view page
            }
        }
        if (contactEditor.pageStack.primaryPage)
            contactEditor.pageStack.primaryPage.forceActiveFocus()
    }
}
