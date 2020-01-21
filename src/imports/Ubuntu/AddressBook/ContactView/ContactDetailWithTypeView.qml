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
import QtContacts 5.0

import Ubuntu.Components 1.3
import Ubuntu.AddressBook.Base 0.1

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
                values.push(overrideValue(detail, fields[i]))
            }
            view.values = values
        }
    }

    function overrideValue(detail, field)
    {
        return detail.value(field)
    }

    activeFocusOnTab: icon.visible
    implicitHeight: view.implicitHeight
    onIsReadyChanged: populateValues()

    Connections {
        target: root.detail
        onDetailChanged: populateValues()
    }

    BasicFieldView {
        id: view

        detail: root.detail
        fields: root.fields
        parentIndex: root.index

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: icon.left
            rightMargin: units.gu(2)
            top: parent.top
        }
    }

    Icon {
        id: icon

        anchors {
            right: parent.right
            rightMargin: units.gu(3)
            verticalCenter: parent.verticalCenter
        }
        width: root.action && (root.action.iconName !== "") ? units.gu(2.5) : 0
        height: width
        name: root.action ? root.action.iconName : ""
        color: root.activeFocus ? theme.palette.normal.focus : theme.palette.normal.base
        visible: width > 0
        asynchronous: true
    }
}
