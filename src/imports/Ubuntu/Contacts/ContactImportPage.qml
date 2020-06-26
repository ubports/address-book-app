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

import QtQuick 2.4

import Ubuntu.Components 1.3
import Ubuntu.Content 1.3 as ContentHub


Page {
    id: root

    // invisible header
    header: Item { height: 0 }
    ContentHub.ContentPeerPicker {
        visible: true
        anchors.fill: parent
        contentType: ContentHub.ContentType.Contacts
        handler: ContentHub.ContentHandler.Source

        onPeerSelected: {
            //fire a request and let the ContentHubProxy do the job of receiving the file and handle errors
            peer.selectionType = ContentHub.ContentTransfer.Single
            peer.request()

        }

        onCancelPressed: {
            pageStack.removePages(root)
         }
    }

}
