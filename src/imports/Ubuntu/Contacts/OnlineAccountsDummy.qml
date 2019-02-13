/*
 * Copyright (C) 2015 Canonical, Ltd.
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

Item {
    id: root

    property bool running: false
    property string applicationId: "address-book"
    property var providerModel: providers
    signal finished()

    function setupExec(provider)
    {
        root.running = true
        fakeEnd.start()
    }

    Timer {
        id: fakeEnd

        running: false
        interval: 500
        onTriggered: {
            root.running = false
            root.finished()
        }
    }

    ListModel {
        id: providers
        ListElement {
            iconName: "testIcon"
            providerId: "testProvider"
            displayName: "Test provider"
        }
    }
}
