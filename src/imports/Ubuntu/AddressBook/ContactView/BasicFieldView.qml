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

 Item {
    id: root

    property alias typeLabel: typeLabel.text
    property alias values: valueList.model
    property double lineHeight: units.gu(2)
    property QtObject detail: null
    property variant fields: null
    property int parentIndex: -1

    activeFocusOnTab: false
    implicitHeight: typeLabel.height + fieldValues.height + units.gu(2)

    Column {
        id: fieldValues

        anchors {
            left: parent.left
            top: parent.top
            topMargin: units.gu(1)
            right: parent.right
        }
        height: (valueList.count * root.lineHeight)

        Repeater {
            id: valueList

            Label {
                id: label
                objectName: detail && fields ? "label_" + detailToString(detail.type, fields[index]) + "_" + root.parentIndex + "." + index : ""

                anchors {
                    left: parent ? parent.left : undefined
                    right: parent ? parent.right : undefined
                }
                height: root.lineHeight
                verticalAlignment: Text.AlignVCenter
                text: modelData ? modelData : ""
                elide: Text.ElideRight

                // style
                fontSize: "medium"
            }
        }
    }

    Label {
        id: typeLabel
        objectName: detail ? "type_" + detailToString(detail.type, -1) + "_" + root.parentIndex : ""

        elide: Text.ElideRight
        visible: text != ""
        anchors {
            left: parent.left
            top: fieldValues.bottom
            //topMargin: units.gu(0.0)
            right: parent.right
        }
        height: visible ? units.gu(2) : 0
        verticalAlignment: Text.AlignVCenter

        // style
        fontSize: "small"
        opacity: 0.8
    }
}
