/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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

import QtQuick 2.2
import QtContacts 5.0
import Ubuntu.Components 1.1
import Ubuntu.Content 1.1 as ContentHub
import "../Common"

Page {
    id: picker

    property alias contactModel: exporter.contactModel
    property var contacts
    property var curTransfer

    ContentHub.ContentPeerPicker {
        visible: true
        anchors.fill: parent
        contentType: ContentHub.ContentType.Contacts
        handler: ContentHub.ContentHandler.Share

        onPeerSelected: {
            exporter.activeTransfer = peer.request();
            if (exporter.activeTransfer.state === ContentHub.ContentTransfer.InProgress) {
                exporter.start(picker.contacts)
            }
        }

        onCancelPressed: {
            if (exporter.activeTransfer) {
                exporter.activeTransfer.state = ContentHub.ContentTransfer.Aborted
            }
            pageStack.pop()
        }
    }

    ContactExporter {
        id: exporter

        onDone: pageStack.pop()
    }
}
