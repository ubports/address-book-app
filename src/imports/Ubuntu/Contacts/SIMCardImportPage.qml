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

import QtQuick 2.4
import QtContacts 5.0

import Ubuntu.Components 1.3
import Ubuntu.Contacts 0.1
import Ubuntu.Components.ListItems 1.3 as ListItem

import MeeGo.QOfono 0.2

Page {
    id: root

    readonly property string exportFile: Contacts.tempFile("ubuntu_contacts_XXXXXX.vcf")
    readonly property alias hasContacts: simCardContacts.hasContacts
    property var targetModel: null
    property var sims: []

    signal importCompleted()

    header: PageHeader {
        id: pageHeader

        title: i18n.dtr("address-book-app", "SIM contacts")
        flickable: contactList.view
        trailingActionBar {
            actions: [
                Action {
                    text: (contactList.selectedItems.count === contactList.count) ?
                              i18n.dtr("address-book-app", "Unselect All") :
                              i18n.dtr("address-book-app", "Select All")
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
                    text: i18n.dtr("address-book-app", "Import")
                    objectName: "confirmImport"

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
        }
    }

    function lockedSIMCount()
    {
        var count = 0
        for(var i=0; i < sims.length; i++) {
            if (sims[i].simMng.pinRequired !== OfonoSimManager.NoPin) {
                count++
            }
        }
        return count
    }

    Timer {
        id: simUnlocking

        interval: 2000
        repeat: false
        running: false
    }

    Column {
        id: lockedSIMList
        anchors {
            left: parent.left
            right: parent.right
        }

        Repeater {
            id: lockedSIMRepeater
            anchors {
                left: parent.left
                right: parent.right
            }
            model: sims.length
            delegate: ListItem.Standard {
                visible: sims[index].simMng.pinRequired !== OfonoSimManager.NoPin
                onVisibleChanged: {
                    if (visible)
                        simUnlocking.stop()
                    else
                        simUnlocking.start()
                }
                text: i18n.dtr("address-book-app", "%1 is locked").arg(sims[index].title)
                control: Button {
                    text: i18n.dtr("address-book-app", "Unlock")
                    onClicked: simCardContacts.unlockModem(sims[index].path)
                }
            }
        }
    }

    ContactListView {
        id: contactList
        objectName: "contactListViewFromSimCard"

        anchors {
            left: parent.left
            right: parent.right
            top: lockedSIMList.bottom
            bottom: parent.bottom
        }
        multiSelectionEnabled: true
        multipleSelection: true
        showSections: false
        visible: !indicator.visible && !statusMessage.visible
        showBusyIndicator: false

        manager: "memory"
        onSelectionCanceled: pageStack.removePages(root)
    }

    Label {
        id: statusMessage

        anchors.centerIn: parent
        text: i18n.dtr("address-book-app", "No contacts found")
        visible: ((contactList.count === 0) &&
                  (root.state === "") &&
                  !contactList.busy &&
                  (sims.length > root.lockedSIMCount()))
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
            if (vcardFile != "" && !contactImported) {
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
        onImportFail: {
            console.error("Sim card import fail")
            root.state = "error"
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
                root.state = "saving"
                targetModel.importContacts(url)
             } else {
                console.error("Failt to export selected contacts")
                root.state = "error"
            }
        }
    }

    Connections {
        target: root.targetModel
        onImportCompleted: {
             if (error === ContactModel.ImportNoError) {
                 Contacts.removeFile(root.exportFile)
                 root.state = ""
                 if (pageStack.removePages)
                     pageStack.removePages(root)
                 else
                     pageStack.pop()
                 root.importCompleted()
             } else {
                 console.error("Fail to import contacts on device")
                 root.state = "error"
             }
        }
    }



    states: [
        State {
            name: "loading"
            when: (simCardContacts.busy || contactList.busy) &&
                   (sims.length > root.lockedSIMCount())
            PropertyChanges {
                target: indicator
                title: i18n.dtr("address-book-app", "Loading...")
                visible: true
            }
        },
        State {
            name: "unlocking"
            when: !simCardContacts.busy && (contactList.count == 0) && (simUnlocking.running)
            PropertyChanges {
                target: indicator
                title: i18n.dtr("address-book-app", "Unlocking...")
                visible: true
            }
        },
        State {
            name: "importing"
            PropertyChanges {
                target: indicator
                title: i18n.dtr("address-book-app", "Reading contacts from SIM...")
                visible: true
            }
        },
        State {
            name: "saving"
            PropertyChanges {
                target: indicator
                title: i18n.dtr("address-book-app", "Saving contacts on phone...")
                visible: true
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: statusMessage
                text: i18n.dtr("address-book-app", "Fail to read SIM card")
                visible: true
            }
        }
    ]

    Component.onDestruction: {
        Contacts.removeFile(root.exportFile)
    }
}
