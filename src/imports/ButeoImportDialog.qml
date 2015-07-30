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
import AddressBookApp 0.1
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0 as Popups

Item {
    id: root

    property var dialog: null
    property bool dismiss: false

    Component {
        id: importDialogComponent

        Popups.Dialog {
            id: buteoDialog

            property bool importCompleted: false

            title: i18n.tr("A new sync service is available.")
            text: i18n.tr("Do you want to import your database to the new service?")
            ActivityIndicator {
                id: importingIndicator

                visible: false
                running: visible
            }

            Button {
                id: notNowButton

                text: i18n.tr("Not now")
                onClicked: PopupUtils.close(buteoDialog)
            }
            Button {
                id: importNowButton

                text: i18n.tr("Import!")
                color: UbuntuColors.green
                enabled: application.isOnline
                onClicked: {
                    var result = buteoImportControl.update(true);
                    if (!result) {
                        console.warn("Fail to import contact database to buteo!")
                    }
                }
            }
            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                text: i18n.tr("* An Internet connection is required to continue.")
                fontSize:"small"
                color: UbuntuColors.red
                visible: !application.isOnline
                wrapMode: Text.WordWrap
            }

            states: [
                State {
                    name: "busy"

                    when: buteoImportControl.busy
                    PropertyChanges {
                        target: buteoDialog
                        text: i18n.tr("Importing..")
                    }
                    PropertyChanges {
                        target: importingIndicator
                        visible: true
                    }
                    PropertyChanges {
                        target: notNowButton
                        visible: false
                    }
                    PropertyChanges {
                        target: importNowButton
                        visible: false
                    }
                },
                State {
                    name: "error"

                    when: (buteoImportControl.lastError !== "")
                    PropertyChanges {
                        target: buteoDialog
                        text: i18n.tr("Fail to import database")
                    }
                    PropertyChanges {
                        target: notNowButton
                        text: i18n.tr("Close")
                    }
                    PropertyChanges {
                        target: importNowButton
                        visible: false
                    }
                },
                State {
                    name: "completed"

                    when: buteoDialog.importCompleted
                    PropertyChanges {
                        target: buteoDialog
                        text: i18n.tr("Database imported")
                    }
                    PropertyChanges {
                        target: notNowButton
                        text: i18n.tr("Close")
                    }
                    PropertyChanges {
                        target: importNowButton
                        visible: false
                    }
                }
            ]

            Component.onDestruction: {
                root.dialog = 0
                root.dismiss = true
            }
        }
    }

    ButeoImport {
        id: buteoImportControl

        Component.onCompleted: {
            if (outDated) {
                dialog = Popups.PopupUtils.open(importDialogComponent, root)
            } else {
                console.debug("Application is ready for buteo.")
                root.dismiss = true
            }
        }

        onUpdateError: {
            console.warn("Fail to import contact database:" + message)
        }

        onUpdated: {
            console.debug("Import Completed")
            if (root.dialog) {
                root.dialog.importCompleted = true
            }
        }
    }
}
