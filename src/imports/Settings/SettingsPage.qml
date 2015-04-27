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
                text: i18n.tr("Add Google account")
                progression: true
                onClicked: onlineAccountsHelper.setupExec()
            }
            ListItem.Standard {
                text: i18n.tr("Import from SIM")
                progression: true
                onClicked: pageStack.push(simCardImportPageComponent)
                enabled: (simList.sims.length > 0) && (simList.present.length > 0)
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
}
