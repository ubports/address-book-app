/*
 * Copyright 2012-2013 Canonical Ltd.
 *
 * This file is part of phone-app.
 *
 * phone-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * phone-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0

FocusScope {
    id: root

    property QtObject contact: null
    property QtObject detail: null
    property bool editable: false
    property bool valid: false

    property Component view
    property Component editor

    states: [
        State {
            name: "view"
            PropertyChanges {
                target: contents
                sourceComponent: view
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: contents
                sourceComponent: editor
            }
        }
    ]

    state: "view"
    implicitHeight: contents.item ? contents.item.height : 0

    Loader {
        id: contents

        anchors.fill: parent
        onItemChanged: {
            if (item.hasOwnProperty("detail")) {
                item.detail = root.detail
            }

            if (item.hasOwnProperty("contact")) {
                item.detail = root.contact
            }
        }
    }
}
