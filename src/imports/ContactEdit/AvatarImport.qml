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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0 as Popups
import Ubuntu.Content 0.1 as ContentHub

Item {
    id: root

    property var activeTransfer: null
    property var loadingDialog: null

    signal avatarReceived(string avatarUrl)

    function requestNewAvatar()
    {
        if (!root.loadingDialog) {
            root.loadingDialog = PopupUtils.open(loadingDialog, null)
            root.activeTransfer = defaultSource.request();
        }
    }

    ContentHub.ContentPeer {
        id: defaultSource

        contentType: ContentHub.ContentType.Pictures
        handler: ContentHub.ContentHandler.Source
        selectionType: ContentHub.ContentTransfer.Single
    }

    Connections {
        target: root.activeTransfer
        onStateChanged: {
            var done = ((root.activeTransfer.state === ContentHub.ContentTransfer.Charged) ||
                        (root.activeTransfer.state === ContentHub.ContentTransfer.Aborted));

            if (root.activeTransfer.state === ContentHub.ContentTransfer.Charged) {
                if (root.activeTransfer.items.length > 0) {
                    root.avatarReceived(root.activeTransfer.items[0].url)
                }
            }

            if (done) {
                PopupUtils.close(root.loadingDialog)
                root.loadingDialog = null
            }
        }
    }

    Component {
        id: loadingDialog

        Popups.Dialog {
            id: dialogue

            title: i18n.tr("Loading")
            ActivityIndicator {
                running: true
                visible: running
            }
        }
    }
}
