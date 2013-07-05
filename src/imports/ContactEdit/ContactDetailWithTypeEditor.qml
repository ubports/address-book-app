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

    property double itemHeight: units.gu(4)
    property alias types: detailTypeCombo.values
    property int fieldType: -1
    property alias selectedTypeIndex: detailTypeCombo.currentIndex

    function selectType(type) {
        detailTypeCombo.selectItem(type)
    }

    function save() {
        // save field values
        for (var i=0; i < fieldValues.children.length; i++) {
            var input = fieldValues.children[i]
            if (input.detail && (input.field >= 0)) {
                input.detail.setValue(input.field, input.text)
            }
        }
    }

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
        }
        height: childrenRect.height

        Repeater {
            model: root.fields

            TextInputDetail {
                detail: root.detail
                field: modelData

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: root.itemHeight
                onRemoveClicked: {
                    root.contact.removeDetail(root.detail)
                }
            }
        }
    }
}
