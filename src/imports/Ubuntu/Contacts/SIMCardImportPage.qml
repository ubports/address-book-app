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

import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Contacts 0.1

Page {
    id: contactEditor
    objectName: "SIMCardImportPage"

    title: i18n.tr("Select contacts to import")

    ContactListView {
        id: contactList
        objectName: "contactListView"

        anchors.fill: parent
        multiSelectionEnabled: true
        multipleSelection: true

        manager: "memory"
        onSelectionCanceled: pageStack.pop()
    }

    SimCardContacts {
        id: simCardContacts
        Component.onCompleted: {
            contactList.listModel.importContacts(simCardContacts.vcardFile)
        }
    }

    head.actions: [
        Action {
            text: (contactList.selectedItems.count === contactList.count) ?
                      i18n.tr("Unselect All") :
                      i18n.tr("Select All")
            iconName: "select"
            onTriggered: {
                if (contactList.selectedItems.count === contactList.count) {
                    contactList.clearSelection()
                } else {
                    contactList.selectAll()
                }
            }
            visible: (contactList.count > 0)
        },
        Action {
            text: i18n.tr("Import")
            iconName: "tick"
            enabled: (contactList.selectedItems.count > 0)
            onTriggered: {
                //TODO
            }
        }
    ]
}
