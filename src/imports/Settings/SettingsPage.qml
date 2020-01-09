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

import Buteo 0.1

Page {
    id: root
    objectName: "settingsPage"

    property var contactListModel

    header: PageHeader {
        id: pageHeader

        title: i18n.tr("Settings")
        flickable: null
    }

    ContactsUI.SIMList {
        id: simList
    }

    MyselfPhoneNumbersModel {
        id: myself
    }

    Flickable {
        id: numberFlickable
        contentHeight: childrenRect.height
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
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

            Repeater {
                model: onlineAccountsHelper.providerModel

                ListItem.Standard {
                    id: addAccountItem
                    property bool selected: (activeFocus && pageStack.hasKeyboard)

                    function activate()
                    {
                        onlineAccountsHelper.setupExec(model.providerId)
                    }

                    text: i18n.tr("Add %1 account").arg(model.displayName)
                    progression: true
                    enabled: buteoSync.serviceAvailable

                    onClicked: activate()
                    Keys.onRightPressed: activate()
                    Keys.onDownPressed: {
                        if (importFromSimItem.enabled) {
                            importFromSimItem.forceActiveFocus()
                        }
                    }
                }
            }
            ListItem.Standard {
                id: importFromSimItem

                property bool selected: (activeFocus && pageStack.hasKeyboard)

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
            }
            SettingsDefaultSyncTarget {
                id: defaultSyncTarget
                onChanged: save()
            }
        }
    }
    ContactsUI.OnlineAccountsHelper {
        id: onlineAccountsHelper
    }

    Binding {
        target: pageStack
        property: 'bottomEdge'
        value: null
    }

    Component {
        id: simCardImportPageComponent

        ContactsUI.SIMCardImportPage {
            id: importFromSimPage

            objectName: "simCardImportPage"
            targetModel: root.contactListModel
            sims: simList.sims
            onImportCompleted: pageStack.removePages(root)
        }
    }

    ButeoSync {
        id: buteoSync
    }

    Keys.onDownPressed: addGoogleAccountItem.forceActiveFocus()
    Keys.onRightPressed: addGoogleAccountItem.forceActiveFocus()
    Keys.onLeftPressed: pageStack.removePages(root)
    Keys.onEscapePressed: pageStack.removePages(root)
    onActiveChanged: {
        if (active) {
            root.forceActiveFocus()
            defaultSyncTarget.update()
        }
    }
}
