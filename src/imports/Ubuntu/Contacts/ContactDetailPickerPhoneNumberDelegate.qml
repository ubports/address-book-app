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

    height: details.height
    anchors {
        left: parent.left
        right: parent.right
    }

    Column {
        id: details
        anchors.top: parent.top
        height: childrenRect.height
        width: parent.width

        Repeater {
            model: contact ? contact.phoneNumbers : undefined
            ListItem.Empty {
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
                        color: "#a3a3a3"
                    }
                    Label {
                        text: number
                        fontSize: "large"
                    }
                }

                onClicked: detailClicked(modelData)
            }
        }
    }
}
