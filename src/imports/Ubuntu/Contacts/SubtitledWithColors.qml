/*
 * Copyright 2012 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3

MouseArea {
    id: subtitledListItem

    property alias text: label.text
    property alias subText: subLabel.text
    property alias textColor: label.color
    property alias subTextColor: subLabel.color

    height: Math.max(middleVisuals.height, units.gu(6))
    Item  {
        id: middleVisuals
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height + label.anchors.topMargin + subLabel.anchors.bottomMargin

        Label {
            id: label
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }
        Label {
            id: subLabel
            anchors {
                left: parent.left
                right: parent.right
                top: label.bottom
            }
            fontSize: "small"
            wrapMode: Text.Wrap
            maximumLineCount: 5
        }
    }
}
