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
import Ubuntu.Content 0.1 as ContentHub

Page {
    id: picker

    property var contactModel
    property var contacts
    property var curTransfer

    ContentHub.ContentPeerPicker {
        visible: true
        anchors.fill: parent
        contentType: ContentHub.ContentType.Contacts
        handler: ContentHub.ContentHandler.Share

        onPeerSelected: {
            picker.curTransfer = peer.request();
            if (picker.curTransfer.state === ContentHub.ContentTransfer.InProgress) {
                var vCardUrl = "file:///tmp/vcard_" + encodeURIComponent(picker.contacts[0].contactId) + ".vcf"
                picker.contactModel.exportContacts(vCardUrl, [], picker.contacts)
            }
        }

        onCancelPressed: pageStack.pop()
    }

    Connections {
        target: picker.contactModel
        onExportCompleted: {
            if (picker.curTransfer && (picker.curTransfer.state === ContentHub.ContentTransfer.InProgress)) {
                if (error === ContactModel.ExportNoError) {
                    var obj = Qt.createQmlObject("import Ubuntu.Content 0.1;  ContentItem { url: '" + url + "' }", picker)
                    picker.curTransfer.items = [ obj ]
                    picker.curTransfer.state = ContentHub.ContentTransfer.Charged
                } else {
                    picker.curTransfer = ContentHub.ContentTransfer.Aborted
                    console.error("Fail to export contact:" + error)
                }
            }
            pageStack.pop()
        }
    }
}
