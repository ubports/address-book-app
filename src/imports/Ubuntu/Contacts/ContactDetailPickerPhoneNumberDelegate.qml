/*
 * Copyright (C) 2012-2013 Canonical, Ltd.
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

import QtQuick 2.0
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components 0.1

Item {
    property QtObject contact: null

    signal detailClicked(QtObject detail)

    ContactDetailPhoneNumberTypeModel {
        id: phoneTypeModel
    }

    height: details.height + units.gu(2)
    anchors {
        left: parent.left
        right: parent.right
    }

    UbuntuShape {
        id: details
        height: childrenRect.height
        color: Qt.rgba(0,0,0,0.1)
        anchors {
            top: parent.top
            //topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }

        Column {
            id: detailItems
            anchors.top: parent.top
            height: childrenRect.height
            width: parent.width

            Repeater {
                id: phoneNumberEntries
                model: contact ? contact.phoneNumbers : undefined
                ListItem.Empty {
                    showDivider: false
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: units.gu(2)
                        anchors.rightMargin: units.gu(2)
                        Label {
                            id: context
                            text: phoneTypeModel.get(phoneTypeModel.getTypeIndex(modelData)).label
                            fontSize: "small"
                            opacity: 0.2
                        }
                        Label {
                            text: number
                            fontSize: "medium"
                        }
                    }

                    onClicked: detailClicked(modelData)
                    Icon {
                        height: units.gu(2)
                        width: units.gu(2)
                        name: "call-start"
                        color: "white"
                        rotation: 90
                        anchors {
                            right: parent.right
                            rightMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    ListItem.ThinDivider {
                        visible: index != 0
                        anchors {
                            bottom: parent.top
                            right: parent.right
                            left: parent.left
                        }
                    }
                }
            }
            ListItem.Empty {
                showDivider: false
                height: units.gu(5)
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(2)
                    anchors.rightMargin: units.gu(2)
                    Label {
                        text: i18n.tr("View contact's profile")
                        fontSize: "medium"
                    }
                }
                onClicked: applicationUtils.switchToAddressbookApp("contact://" + contact.contactId)
                Icon {
                    height: units.gu(2)
                    width: units.gu(2)
                    name: "contact"
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                }
                ListItem.ThinDivider {
                    visible: phoneNumberEntries.count !== 0
                    anchors {
                        bottom: parent.top
                        right: parent.right
                        left: parent.left
                    }
                }
            }
        }
    }
}
