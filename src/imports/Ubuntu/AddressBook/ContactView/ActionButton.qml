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

AbstractButton {
    id: root

    property QtObject actions
    property alias iconName: icon.name
    property real iconSize: units.gu(2.5)

    Icon {
        id: icon

        anchors.centerIn: parent
        height: root.iconSize
        width: root.iconSize
        color: root.activeFocus ? theme.palette.normal.focus : theme.palette.normal.base
        asynchronous: true
    }
}
