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

AbstractButton {
    id: messageActions

    property QtObject actions
    property alias iconSource: icon.source

    Item {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: arrow.top
        }
        Image {
            id: icon
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            smooth: true
            height: units.gu(3)
            width: height
        }
    }

    Item {
        id: arrow

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(2)
        Image {
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            smooth: true
            height: units.gu(2)
            width: height
            source: "artwork:/action-list.png"
        }
    }
}
