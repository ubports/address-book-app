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

TextField {
    id: root

    property QtObject detail
    property int field: -1
    property variant originalValue: root.detail && (root.field >= 0) ? root.detail.value(root.field) : null

    signal removeClicked()

    hasClearButton: false
    text: originalValue ? originalValue : ""

    secondaryItem: AbstractButton {
        id: removeButton

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(1)
        }
        width: units.gu(2)
        height: units.gu(2)

        Image {
            anchors.fill: parent
            source: "artwork:/edit-remove.png"
            fillMode: Image.PreserveAspectFit
        }

        onClicked: root.removeClicked()
    }
}
