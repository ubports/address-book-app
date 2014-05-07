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
import Ubuntu.Components 0.1
import QtContacts 5.0
import Ubuntu.Components.ListItems 0.1 as ListItem

import "../Common"

ContactDetailBase {
    id: root

    property bool active: false
    property double itemHeight: units.gu(3)
    property alias types: detailTypeSelector.values
    property int fieldType: -1
    property alias selectedTypeIndex: detailTypeSelector.currentIndex
    property variant placeholderTexts: []
    property int inputMethodHints: Qt.ImhNone

    function selectType(type) {
        detailTypeSelector.selectItem(type)
    }

    function isEmpty() {
        for (var i=0; i < fieldValues.children.length; i++) {
            var input = fieldValues.children[i]
            if (input.text && (input.text !== "")) {
                return false
            }
        }
        return true
    }

    function save() {
        var detailchanged  = false

        // save field values
        for (var i=0; i < fieldValues.children.length; i++) {
            var input = fieldValues.children[i]
            if (input.detail && (input.field >= 0)) {
                if (input.text !== "") {
                    var originalValue = input.detail.value(input.field)
                    originalValue = originalValue ? String(originalValue) : ""
                    if (originalValue !== input.text) {
                        root.detail.setValue(input.field, input.text)
                        detailchanged  = true
                    }
                }
            }
        }

        return detailchanged
    }

    // disable listview mouse area
    __mouseArea.visible: false
    enabled: root.detail ? !root.detail.readOnly : false
    implicitHeight: detailTypeSelector.height + fieldValues.height + units.gu(2)
    opacity: enabled ? 1.0 : 0.5
    ValueSelector {
        id: detailTypeSelector
        objectName: detail ? "type_" + detailToString(detail.type, -1) + "_" + index : ""

        readOnly: root.detail ? root.detail.readOnly : false
        visible: (currentIndex != -1)
        active: root.active
        anchors {
            left: parent.left
            leftMargin: units.gu(3)
            right: parent.right
            rightMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(1)
        }

        height: visible ? (root.active ? units.gu(4) : units.gu(3)) : 0
        onExpandedChanged: {
            // Make sure that the inputfield get focus when clicking on type selector
            if (expanded) {
                root.forceActiveFocus()
            }
        }
    }

    Column {
        id: fieldValues

        anchors {
            left: detailTypeSelector.left
            right: detailTypeSelector.right
            top: detailTypeSelector.bottom
        }
        height: childrenRect.height

        Repeater {
            id: fieldRepeater

            model: root.fields
            TextInputDetail {
                id: detail
                objectName: root.detail ? detailToString(root.detail.type, modelData) + "_" + root.index : ""

                detail: root.detail
                field: modelData
                placeholderText: root.placeholderTexts[index]
                inputMethodHints: root.inputMethodHints
                onActiveFocusChanged: root.active = activeFocus
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: root.active ? root.itemHeight + units.gu(1) : root.itemHeight
                onRemoveClicked: root.contact.removeDetail(root.detail)
            }
        }
        Keys.onReleased: {
            if ((event.key == Qt.Key_Right) && (event.modifiers & Qt.ShiftModifier)) {
                detailTypeSelector.moveNext()
                event.accepted = true
            } else if ((event.key == Qt.Key_Left) && (event.modifiers & Qt.ShiftModifier)) {
                detailTypeSelector.movePrevious()
                event.accepted = true
            }
        }
    }
}
