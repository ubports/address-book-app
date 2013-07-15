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

    property QtObject availabelActions
    property alias subtitle: subtitle
    property double itemHeight: units.gu(3)
    property string defaultIcon

    signal actionTrigerred(string action, QtObject contact)

    implicitHeight: units.gu(6)

    Image {
        id: primaryIcon

        property variant action: availabelActions && (availabelActions.children.length > 0) ? availabelActions.children[0] : null

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }
        height: units.gu(2)
        width: units.gu(2)
        source: action && action.iconSource && action.iconSource != "" ? action.iconSource : defaultIcon
    }

    Label {
        id: subtitle

        anchors {
            left: primaryIcon.right
            leftMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }

        // style
        fontSize: "x-small"
        color: "#f3f3e7"
        opacity: 0.2
    }

    Label {
        id: title

        anchors {
            left: subtitle.left
            top: subtitle.bottom
            right: comboIcon.left
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }

        verticalAlignment: Text.AlignVCenter
        text: root.detail && fields.length > 0 ? root.detail.value(fields[0]) : ""

        // style
        fontSize: "medium"
        color: "#f3f3e7"
    }

    Image {
        id: comboIcon

        anchors {
            verticalCenter: parent.verticalCenter
            right: secondaryIcon.left
        }
        height: units.gu(2)
        width: visible ? units.gu(2) : 0
        visible: availabelActions && (availabelActions.children.length > 2)
        source: "artwork:/action-list.png"
    }

    MouseArea {
        id: secondaryIcon

        property variant action: availabelActions && (availabelActions.children.length > 1) ? availabelActions.children[1] : null

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: visible ? units.gu(4) : 0
        visible: action != null

        Image {
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            source: secondaryIcon && secondaryIcon.action ? secondaryIcon.action.iconSource : ""
            width: units.gu(2)
            height: units.gu(2)
        }
    }

    onClicked: {
        if (availabelActions && (availabelActions.children.length > 0)) {
            actionTrigerred(availabelActions.children[0], contact)
        }
    }
}
