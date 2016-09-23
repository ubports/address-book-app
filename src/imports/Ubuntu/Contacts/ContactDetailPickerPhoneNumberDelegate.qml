/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import QtContacts 5.0 as QtContacts

Item {
    id: root

    signal detailClicked(QtObject detail, string action)
    signal addDetailClicked(int detailType)

    function containsPointer(item, point)
    {
        return ((point.x >= item.x) && (point.x <= item.x + item.width) &&
                (point.y >= item.y) && (point.y <= item.y + item.height));
    }

    function updateDetails(contact)
    {
        if (contact) {
            phoneNumberEntries.model = contact.details(QtContacts.ContactDetail.PhoneNumber)
        }
    }

    height: detailItems.height + units.gu(2)
    Column {
        id: detailItems

        anchors {
            top: parent.top
            topMargin: units.gu(1)
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
        width: parent.width

        Item {
            id: noNumberMessage

            anchors {
                left: parent.left
                right: parent.right
            }

            height: visible ? units.gu(8) : 0
            Rectangle {
                anchors {
                    fill: parent
                    leftMargin: units.gu(-2)
                    rightMargin: units.gu(-2)
                }
                color: Theme.palette.selected.background
                opacity: noNumberMessageArea.pressed ?  1.0 : 0.0
                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }
            }
            Label {
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: units.gu(8)
                    right: parent.right
                }

                text: i18n.dtr("address-book-app", "Add number...")
            }
            visible: phoneNumberEntries.count == 0
            MouseArea {
                id: noNumberMessageArea

                anchors.fill: parent
                enabled: parent.visible
                onClicked: root.addDetailClicked(QtContacts.ContactDetail.PhoneNumber)
            }
        }

        Repeater {
            id: phoneNumberEntries

            SubtitledWithColors {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(6)
                    right: parent.right
                }
                text: modelData.number
                subText: phoneTypeModel.get(phoneTypeModel.getTypeIndex(modelData)).label
                onClicked: root.detailClicked(modelData, "call")

                MouseArea {
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                        rightMargin: units.gu(1)
                    }
                    width: units.gu(4)

                    z: 100
                    onClicked: root.detailClicked(modelData, "message")
                    Icon {
                        id: messageIcon

                        name: "message"
                        height: units.gu(3)
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                    }
                }
            }
        }
    }

    ContactDetailPhoneNumberTypeModel {
        id: phoneTypeModel
    }
}
