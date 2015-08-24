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
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0 as Popups

Item {
    id: root

    property var dialog: null
    property bool dismiss: false

    function start()
    {
        if (root.dialog) {
            console.debug("Dialog already open")
            return
        }

        root.dialog = Popups.PopupUtils.open(importDialogComponent, root)
        if (application.isOnline) {
            buteoImportControl.update(true)
        }
    }

    Component {
        id: importDialogComponent

        Popups.Dialog {
            id: buteoDialog

            property string errorMessage: ""

            function showError(errorCode)
            {
                var errorString = ""
                switch(errorCode)
                {
                case ButeoImport.OnlineAccountNotFound:
                    errorString = i18n.tr("Fail to connect with contact sync service.")
                    break;
                case ButeoImport.FailToConnectWithButeo:
                    errorString = i18n.tr("Fail to connect with contact sync service.")
                    break;
                case ButeoImport.FailToCreateButeoProfiles:
                    errorString = i18n.tr("Fail to create contact sync profile.")
                    break;
                case ButeoImport.SyncAlreadyRunning:
                    errorString = i18n.tr("Contact sync already in progress.")
                    break;
                case buteoImport.SyncError:
                    errorString = i18n.tr("Fail to sync account.")
                    break;
                case ButeoImport.InernalError:
                default:
                    break;
                }
                buteoDialog.title = i18n.tr("Could not complete contact sync upgrade.")
                buteoDialog.errorMessage = i18n.tr("%1.\nOnly local contacts will be editable until upgrade is complete. Please try again by pressing sync button").arg(errorString)
                state = "error"
            }

            title: i18n.tr("A new sync service is available.")
            text: i18n.tr("Contact sync upgrade in progress...")
            ActivityIndicator {
                id: importingIndicator

                visible: running
                running: true
            }

            Button {
                id: closeButton

                text: i18n.tr("Close")
                visible: false
                onClicked: PopupUtils.close(buteoDialog)
            }

            states: [
                State {
                    name: "error"

                    PropertyChanges {
                        target: buteoDialog
                        title: i18n.tr("Fail to upgrade")
                        text: buteoDialog.errorMessage
                    }

                    PropertyChanges {
                        target: closeButton
                        visible: true
                        color: UbuntuColors.red
                    }

                    PropertyChanges {
                        target: importingIndicator
                        running: false
                    }
                },
                State {
                    name: "noInternet"
                    when: !application.isOnline

                    PropertyChanges {
                        target: buteoDialog
                        text: i18n.tr("Your contact sync needs to be upgraded, but no network connection could be found. Please connect to network and retry by pressing sync button.\nOnly local contacts will be editable until upgrade is complete.")
                    }

                    PropertyChanges {
                        target: closeButton
                        visible: true
                    }

                    PropertyChanges {
                        target: importingIndicator
                        running: false
                    }
                }
            ]

            Component.onDestruction: {
                root.dialog = null
            }
        }
    }

    ButeoImport {
        id: buteoImportControl

        Component.onCompleted: {
            if (outDated) {
                root.start()
            } else {
                console.debug("Application is ready for buteo.")
                root.dismiss = true
            }
        }

        onUpdateError: {
            console.warn("Fail:" + errorCode)
            root.dialog.showError(errorCode)
        }

        onUpdated: {
            console.debug("Import Completed")
            PopupUtils.close(root.dialog)
            root.dismiss = true
        }
    }
}
