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
import Ubuntu.Contacts 0.1

ContactDetailBase {
    id: root

    readonly property alias fieldDelegates: fieldsColumn.children
    property alias fieldDelegate: fieldRepeater.delegate
    property alias spacing: fieldsColumn.spacing

    implicitHeight: fieldsColumn.height
    Column {
        id: fieldsColumn

        anchors {
            left: parent.left
            right: parent.right
        }
        spacing: units.gu(2)

        //height: childrenRect.height
        Repeater {
            id: fieldRepeater

            model: root.fields
            onItemAdded: {
                item.field = Qt.binding(function() { return model[index] })
                item.detail = Qt.binding(function() { return root.detail })
            }
        }
    }
}
