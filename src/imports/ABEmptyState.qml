/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
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

Column {
    id: root

    property alias text: emptyStateLabel.text

    spacing: units.gu(2)
    //implicitHeight: childrenRect.height

    Behavior on visible {
        SequentialAnimation {
             PauseAnimation {
                 duration: !root.visible ? 500 : 0
             }
             PropertyAction {
                 target: root
                 property: "visible"
             }
        }
    }

    Icon {
        id: emptyStateIcon
        anchors.horizontalCenter: emptyStateLabel.horizontalCenter
        height: units.gu(5)
        width: units.gu(5)
        opacity: 0.3
        name: "contact"
        asynchronous: true
    }
    Label {
        id: emptyStateLabel
        anchors {
            left: parent.left
            right: parent.right
        }
        height: paintedHeight
        text: i18n.tr("Create a new contact by swiping up from the bottom of the screen.")
        color: theme.palette.normal.backgroundSecondaryText
        fontSize: "x-large"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
}
