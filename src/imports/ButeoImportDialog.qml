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
import QtSystemInfo 5.0
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
        } else {
            root.dialog.state = "noInternet"
        }
    }

    Component {
        id: importDialogComponent

        Popups.Dialog {
            id: buteoDialog

            property string errorMessage: ""

            function showError(accountName, errorCode)
            {
                var errorString = ""
                switch(errorCode)
                {
                case ButeoImport.OnlineAccountNotFound:
                    errorString = i18n.tr("Fail to connect with online accounts service.")
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
                case ButeoImport.SyncError:
                    errorString = i18n.tr("Fail to sync account.")
                    break;
                case ButeoImport.InernalError:
                default:
                    break;
                }
                //FIXME: Use a generic message instead of explicitly say "Google"
                buteoDialog.title = i18n.tr("Could not complete %1 sync upgrade.").arg(accountName !== "" ? accountName : "Google contacts")
                buteoDialog.errorMessage = i18n.tr("%1.\nOnly local contacts will be editable until upgrade is complete. Please try again by pressing sync button").arg(errorString)
                state = "error"
            }

            //FIXME: Use a generic message instead of explicitly say "Google"
            title: i18n.tr("Google contact sync upgrade in progress...")
            text: ""
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

            ScreenSaver {
                id: screenSaver

                // prevent the screen to goes off while syncing
                screenSaverEnabled: false
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

                    PropertyChanges {
                        target: screenSaver
                        screenSaverEnabled: true
                    }
                },
                State {
                    name: "noInternet"

                    PropertyChanges {
                        target: buteoDialog
                        title: i18n.tr("Device offline")
                        //FIXME: Use a generic message instead of explicitly say "Google"
                        text: i18n.tr("Your Google contact sync needs to be upgraded, but no network connection could be found.\nPlease connect to network and retry by pressing sync button.\nOnly local contacts will be editable until upgrade is complete.")
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

                    PropertyChanges {
                        target: screenSaver
                        screenSaverEnabled: true
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
            root.dialog.showError(accountName, errorCode)
        }

        onUpdated: {
            console.debug("Import Completed")
            PopupUtils.close(root.dialog)
            root.dismiss = true
        }
    }
}
