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
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Contacts 0.1 as ContactsUI

Page {
    id: root
    objectName: "settingsPage"

    property var contactListModel

    title: i18n.tr("Settings")

    ContactsUI.SIMList {
        id: simList
    }

    MyselfPhoneNumbersModel {
        id: myself
    }

    flickable: null
    Flickable {
        id: numberFlickable
        contentHeight: childrenRect.height
        anchors.fill: parent
        clip: true

        Column {
            anchors{
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height + units.gu(4)

            Repeater {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                model: myself
                delegate: ListItem.Subtitled {
                   text:  i18n.tr("My phone number: %1").arg(phoneNumber)
                   subText: network != "" ? network : i18n.tr("SIM %1").arg(index)
                }
                onCountChanged: numberFlickable.contentY = 0
            }
            ListItem.Standard {
                id: addGoogleAccountItem

                function activate()
                {
                    onlineAccountsHelper.setupExec()
                }

                text: i18n.tr("Add Google account")
                progression: true

                onClicked: addGoogleAccountItem.activate()
                Keys.onRightPressed: addGoogleAccountItem.activate()
                Keys.onDownPressed: {
                    if (importFromSimItem.enabled) {
                        importFromSimItem.forceActiveFocus()
                    }
                }

                // Selection visual feedback
                //
                // FIXME: Using a private property here. This uses the old list item and the only way to change the text
                // color is with this property.
                // We should remove it when update the app to the new ListItem.
                __foregroundColor: (activeFocus && (pageStack.columns > 1)) ? Theme.palette.normal.foregroundText :
                                                                              Theme.palette.normal.foreground
                Rectangle {
                    color: UbuntuColors.orange
                    anchors.fill: parent
                    visible:addGoogleAccountItem.activeFocus
                    z: -1
                }
            }
            ListItem.Standard {
                id: importFromSimItem

                function activate()
                {
                    pageStack.addPageToCurrentColumn(root, simCardImportPageComponent)
                }

                text: i18n.tr("Import from SIM")
                progression: true
                enabled: (simList.sims.length > 0) && (simList.present.length > 0)
                onClicked: importFromSimItem.activate()
                Keys.onRightPressed: importFromSimItem.activate()
                Keys.onUpPressed: addGoogleAccountItem.forceActiveFocus()

                // selection visual feedback
                //
                // FIXME: Using a private property here. This uses the old list item and the only way to change the text
                // color is with this property.
                // We should remove it when update the app to the new ListItem.
                __foregroundColor: (activeFocus && (pageStack.columns > 1)) ? Theme.palette.normal.foregroundText :
                                                                              Theme.palette.normal.foreground
                Rectangle {
                    color: UbuntuColors.orange
                    anchors.fill: parent
                    visible: importFromSimItem.activeFocus
                    z: -1
                }
            }
        }
    }
    ContactsUI.OnlineAccountsHelper {
        id: onlineAccountsHelper
    }

    Component {
        id: simCardImportPageComponent

        ContactsUI.SIMCardImportPage {
            objectName: "simCardImportPage"
            targetModel: root.contactListModel
            sims: simList.sims
        }
    }

    Keys.onDownPressed: addGoogleAccountItem.forceActiveFocus()
    Keys.onRightPressed: addGoogleAccountItem.forceActiveFocus()
    Keys.onLeftPressed: pageStack.removePages(root)
    Keys.onEscapePressed: pageStack.removePages(root)
    onActiveChanged: {
        if (active) {
            root.forceActiveFocus()
        }
    }
}
