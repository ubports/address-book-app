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
import Ubuntu.Components.ListItems 0.1 as ListItem

ContactDetailBase {
    id: root

    readonly property alias fieldDelegates: fieldsColumn.children
    property Component fieldDelegate: null

    implicitHeight: fieldsColumn.height

    Column {
        id: fieldsColumn

        anchors {
            left: parent.left
            right: parent.right
        }
        spacing: units.gu(2)

        height: childrenRect.height
        Repeater {
            id: fieldRepeater

            model: root.fields
            Loader {
                id: field
                focus: true

                sourceComponent: fieldDelegate

                Binding {
                    target: item
                    property: "field"
                    value: modelData
                }

                Binding {
                    target: item
                    property: "detail"
                    value: root.detail
                }

                KeyNavigation.backtab : index > 0 ? fieldRepeater.itemAt(index - 1) : null
                KeyNavigation.tab: index < fieldRepeater.count - 1 ? fieldRepeater.itemAt(index + 1) : null
            }
        }
    }
}
