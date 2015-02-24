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
import QtContacts 5.0
import Ubuntu.Components 1.1
import Ubuntu.Contacts 0.1

Page {
    id: root
    objectName: "SIMCardImportPage"

    readonly property string exportFile: "file:///tmp/ubuntu_contacts_sim.vcf"
    readonly property alias hasContacts: simCardContacts.hasContacts
    property var targetModel: null

    title: i18n.tr("Import contacts")

    ContactListView {
        id: contactList
        objectName: "contactListViewFromSimCard"

        anchors.fill: parent
        multiSelectionEnabled: true
        multipleSelection: true
        showSections: false
        visible: !indicator.visible

        manager: "memory"
        onSelectionCanceled: pageStack.pop()
    }

    Column {
        id: indicator

        property alias title: activityLabel.text

        anchors.centerIn: root
        spacing: units.gu(2)
        visible: false

        ActivityIndicator {
            id: activity

            anchors.horizontalCenter: parent.horizontalCenter
            running: indicator.visible
        }
        Label {
            id: activityLabel

            anchors.horizontalCenter: activity.horizontalCenter
        }
    }

    SimCardContacts {
        id: simCardContacts

        property bool contactImported: false

        Component.onCompleted: {
            root.state = "loading"
            if (vcardFile != "") {
                contactImported = true
                contactList.listModel.importContacts(vcardFile)
            }
        }
        onVcardFileChanged: {
            if ((vcardFile != "") && !contactImported) {
                contactImported = true
                contactList.listModel.importContacts(vcardFile)
            }
        }
    }

    Connections {
        target: contactList.listModel
        onImportCompleted: {
            contactList.startSelection()
            root.state = ""
        }

        onExportCompleted: {
            if ((error === ContactModel.ExportNoError) && targetModel) {
                targetModel.importContacts(url)
             }
             pageStack.pop()
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
                root.state = "importing"
                var contacts = []
                var items = contactList.selectedItems

                for (var i=0, iMax=items.count; i < iMax; i++) {
                    contacts.push(items.get(i).model.contact)
                }

                contactList.listModel.exportContacts(root.exportFile,
                                                     [],
                                                     contacts)
            }
        }
    ]

    states: [
        State {
            name: "loading"
            PropertyChanges {
                target: indicator
                title: i18n.tr("Loading")
                visible: true
            }
        },
        State {
            name: "importing"
            PropertyChanges {
                target: indicator
                title: i18n.tr("Importing")
                visible: true
            }
        }
    ]
}
