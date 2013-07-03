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
import Ubuntu.Components.Popups 0.1 as Popups

ContactDetailEditor {
    id: root

    property double itemHeight: units.gu(5)
    property alias types: detailTypeCombo.values
    property alias selectedTypeIndex: detailTypeCombo.currentIndex

    implicitHeight: fieldValues.height

    Combobox {
        id: detailTypeCombo

        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: units.gu(10)
    }

    Column {
        id: fieldValues

        anchors {
            left: detailTypeCombo.right
            right: parent.right
            margins: units.gu(1)
        }
        height: childrenRect.height

        Repeater {
            model: detail ? root.fields : 0
            TextInputDetail {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: root.itemHeight
                text: root.detail ? root.detail.value(modelData) : ""
            }
        }
    }
}
