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

import QtQuick 2.2
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components 0.1

Item {
    id: root

    signal detailClicked(QtObject detail, string action)

    function containsPointer(item, point)
    {
        return ((point.x >= item.x) && (point.x <= item.x + item.width) &&
                (point.y >= item.y) && (point.y <= item.y + item.height));
    }

    function updateDetails(contact)
    {
        phoneNumberEntries.model = contact.phoneNumbers
    }

    height: detailItems.height + units.gu(2)
    Column {
        id: detailItems

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
        width: parent.width

        ListItem.Standard {
            id: noNumberMessage
            showDivider: false
            text: "No phone numbers."
            visible: phoneNumberEntries.count == 0
        }

        Repeater {
            id: phoneNumberEntries

            model: contact.phoneNumbers
            ListItem.Subtitled {
                anchors {
                    left: parent.left
                    leftMargin: units.gu(7)
                    right: parent.right
                }
                showDivider: false
                // TODO: change text font color to UbuntuColors.lightAubergine
                // see bug #1324128
                text: number
                subText: phoneTypeModel.get(phoneTypeModel.getTypeIndex(modelData)).label
                onClicked: root.detailClicked(modelData, "")

                Row {
                    id: icons

                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: parent.bottom
                    }

                    width: childrenRect.width
                    spacing: units.gu(2)

                    Icon {
                        id: messageIcon

                        name: "message"
                        height: units.gu(3)
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Icon {
                        id: callIcon

                        name: "call-start"
                        height: units.gu(3)
                        width: height
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                // WORKAROUND: SDK ListItem.Subtitled does not provide the mouse arg on onClicked event
                // without that we can not check where the user clicked
                MouseArea {
                    anchors.fill: icons
                    z: 100
                    onClicked: {
                        var point = Qt.point(mouse.x, mouse.y)
                        if (root.containsPointer(messageIcon, point))
                            root.detailClicked(modelData, "message")
                        if (root.containsPointer(callIcon, point))
                            root.detailClicked(modelData, "call")
                    }
                }
            }
        }
    }

    ContactDetailPhoneNumberTypeModel {
        id: phoneTypeModel
    }
}
