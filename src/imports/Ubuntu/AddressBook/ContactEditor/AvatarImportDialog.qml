/*
 * Copyright (C) 2016 Canonical, Ltd.
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
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3

PopupBase {
    id: dialogue

    property alias activeTransfer: signalConnections.target
    signal avatarReceived(string avatarUrl)
    signal destruction()

    parent: QuickUtils.rootItem(this)
    focus: true

    Rectangle {
        anchors.fill: parent

        ContentTransferHint {
            anchors.fill: parent
            activeTransfer: dialogue.activeTransfer
        }

        ContentPeerPicker {
            id: peerPicker

            anchors.fill: parent
            contentType: ContentType.Pictures
            handler: ContentHandler.Source

            onPeerSelected: {
                peer.selectionType = ContentTransfer.Single
                dialogue.activeTransfer = peer.request()
            }

            onCancelPressed: {
                PopupUtils.close(dialogue)
            }
        }
    }

    Connections {
        id: signalConnections

        onStateChanged: {
            var done = ((dialogue.activeTransfer.state === ContentTransfer.Charged) ||
                        (dialogue.activeTransfer.state === ContentTransfer.Aborted))

            if (dialogue.activeTransfer.state === ContentTransfer.Charged) {
                if (dialogue.activeTransfer.items.length > 0) {
                    dialogue.avatarReceived(dialogue.activeTransfer.items[0].url)
                }
            }

            if (done) {
                acceptTimer.restart()
            }
        }
    }

    // WORKAROUND: Work around for application becoming insensitive to touch events
    // if the dialog is dismissed while the application is inactive.
    // Just listening for changes to Qt.application.active doesn't appear
    // to be enough to resolve this, so it seems that something else needs
    // to be happening first. As such there's a potential for a race
    // condition here, although as yet no problem has been encountered.
    Timer {
        id: acceptTimer

        interval: 100
        repeat: true
        running: false
        onTriggered: {
            if(Qt.application.state === Qt.ApplicationActive) {
               PopupUtils.close(dialogue)
           }
        }
    }

    Component.onDestruction: dialogue.destruction()
}
