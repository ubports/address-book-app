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
import Ubuntu.Components 0.1
import QtContacts 5.0
import Ubuntu.Components.ListItems 0.1 as ListItem

import "../Common"

ContactDetailBase {
    id: root

    property QtObject action
    property alias subtitle: subtitle
    property double itemHeight: units.gu(3)
    property string defaultIcon

    signal actionTrigerred(string action, QtObject contact)

    implicitHeight: contents.childrenRect.height + units.gu(1)

    Label {
        id: subtitle

        anchors {
            left: parent.left
            top: parent.top
            topMargin: units.gu(1)
        }

        // style
        fontSize: "x-small"
        color: "#f3f3e7"
        opacity: 0.2
    }

    Column {
        id: contents

        anchors {
            top: parent.top
            right: actionIcon.left
            bottom: parent.bottom
        }

        width: units.gu(25)

        Repeater {
            model: 3

            Label {
                id: title

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: root.itemHeight
                verticalAlignment: Text.AlignVCenter
                text: root.detail && fields.length > 0 ? root.detail.value(modelData) : ""

                // style
                fontSize: "medium"
                color: "#f3f3e7"
            }
        }
    }

    Item {
        id: actionIcon

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: visible ? units.gu(4) : 0
        visible: action != null

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            source: root.action.iconSource
            width: units.gu(2)
            height: units.gu(2)
        }
    }

    onClicked: {
        if (action) {
            actionTrigerred(action.text, contact)
        }
    }
}
