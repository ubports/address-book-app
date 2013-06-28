/*
 * Copyright 2012-2013 Canonical Ltd.
 *
 * This file is part of address-book-app.
 *
 * phone-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * phone-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import QtContacts 5.0
import Ubuntu.Components.ListItems 0.1 as ListItem

ContactDetailView {
    id: root

    property variant fields
    property alias subtitle: subtitle
    property alias actionIcon: action.source
    property double itemHeight: units.gu(3)

    implicitHeight: fieldValues.height

    Rectangle {
        anchors.fill: parent
        border.color: "black"
        border.width: 1

        Column {
            id: fieldValues

            spacing: 0
            anchors {
                left: parent.left
                right: subtitle.left
                margins: units.gu(1)
            }
            y: units.gu(1) // margin
            height: childrenRect.height + units.gu(2) // margin

            Repeater {
                model: detail ? root.fields : 0

                Label {
                    id: title

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    verticalAlignment: Text.AlignVCenter
                    height: root.itemHeight
                    fontSize: "medium"
                    text: root.detail ? root.detail.value(modelData) : ""
                }
            }
        }


        Label {
            id: subtitle

            anchors {
                verticalCenter: div.verticalCenter
                right: div.right
                rightMargin: units.gu(1)
            }
            horizontalAlignment: Text.AlignRight
            width: units.gu(6)
            fontSize: "small"
        }

        Rectangle {
            id: div

            color: "gray"
            anchors {
                top: parent.top
                topMargin: units.gu(1)
                right: action.left
                rightMargin: units.gu(1)
            }
            width: 1
            height: units.gu(3)
            border.width: 0
        }

        Image {
            id: action
            anchors {
                verticalCenter: div.verticalCenter
                right: parent.right
                rightMargin: units.gu(1)
            }
            height: units.gu(2)
            width: units.gu(2)
        }
    }
}
