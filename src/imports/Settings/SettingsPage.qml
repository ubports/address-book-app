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
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Contacts 0.1 as ContactsUI

Page {
    id: settingsPage
    objectName: "settingsPage"

    property var contactListModel

    title: i18n.tr("Settings")

    MyselfPhoneNumbersModel {
        id: myself
    }

    Column {
        anchors.fill: parent

        Repeater {
            anchors {
                left: parent.left
                right: parent.right
            }
            model: myself
            delegate: ListItem.Base {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(8)

                UbuntuShape {
                    id: uShape

                    anchors {
                        left: parent.left
                        top: parent.top
                        topMargin: units.gu(1)
                        bottom: parent.bottom
                        bottomMargin: units.gu(1)
                    }
                    width: height
                    radius: "medium"
                    color: Theme.palette.normal.overlay

                    Label {
                        id: initialsLabel

                        anchors.centerIn: parent
                        text: i18n.tr("ME")
                        font.pointSize: 88
                        color: UbuntuColors.lightAubergine
                    }
                }

                Label {
                    id: name

                    anchors {
                        left: uShape.right
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                    color: UbuntuColors.lightAubergine
                    elide: Text.ElideRight
                    text: phoneNumber
                }
            }
        }
        ListItem.Standard {
            text: i18n.tr("Add Google account")
            progression: true
            onClicked: onlineAccountsHelper.setupExec()
        }
        ListItem.Standard {
            text: i18n.tr("Import from SIM")
            progression: true
            onClicked: pageStack.push(simCardImportPageComponent)
        }
    }

    ContactsUI.OnlineAccountsHelper {
        id: onlineAccountsHelper
    }

    Component {
        id: simCardImportPageComponent

        ContactsUI.SIMCardImportPage {
            objectName: "simCardImportPage"
            targetModel: settingsPage.contactListModel
        }
    }
}
