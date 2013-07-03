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

Rectangle {
    property alias text:input.text

    border.color: "black"
    border.width: 1
    implicitHeight: input.height

    TextInput {
        id: input

        clip: true
        anchors {
            left: parent.left
            right: removeButton.left
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        height: units.gu(2)
    }

    AbstractButton {
        id: removeButton

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(1)
        }
        width: units.gu(2)
        height: units.gu(2)
        //visible: detailEditor.visible

        Image {
            anchors.fill: parent
            source: "artwork:/edit-remove.png"
            fillMode: Image.PreserveAspectFit
        }
    }
}
