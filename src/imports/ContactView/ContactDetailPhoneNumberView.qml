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
import Ubuntu.Components 1.1
import QtContacts 5.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../Common"

ContactDetailBase {
    id: root

    property alias typeLabel: view.typeLabel
    property alias lineHeight: view.lineHeight
    readonly property bool isReady: (fields != null) && (detail != null)

    function populateValues()
    {
        if (isReady) {
            var values = []
            for(var i=0; i < fields.length; i++) {
                values.push(detail.value(fields[i]))
            }
            view.values = values
        }
    }

    implicitHeight: view.implicitHeight
    onIsReadyChanged: populateValues()
    Connections {
        target: root.detail
        onDetailChanged: populateValues()
    }

    BasicFieldView {
        id: view

        parentIndex: root.index
        detail: root.detail
        fields: root.fields

        anchors {
            left: parent.left
            top: parent.top
            right: messageActions.left
            bottom: parent.bottom
            leftMargin: units.gu(2)
        }
    }

    ActionButton {
        id: messageActions

        anchors {
            right: callActions.left
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(4)
        height: units.gu(4)
        iconName: "message"
        onClicked: Qt.openUrlExternally("message:///" + encodeURIComponent(view.values[0]))
    }


    ActionButton {
        id: callActions

        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            top: parent.top
            verticalCenter: parent.verticalCenter
        }
        width: units.gu(4)
        height: units.gu(4)
        iconName: "call-start"
        onClicked: Qt.openUrlExternally("tel:///" + encodeURIComponent(view.values[0]))
    }

}
