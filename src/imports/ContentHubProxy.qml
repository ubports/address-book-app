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

import QtQuick 2.2
import Ubuntu.Content 0.1 as ContentHub

QtObject {
    property Component pageStack: null

    Connections {
        target: ContentHub.ContentHub
        onExportRequested: {
            // enter in pick mode
            pageStack.push(Qt.createComponent("ContactList/ContactListPage.qml"),
                           {pickMode: true,
                            contentHubTransfer: transfer})
        }
        onImportRequested: {
            if (transfer.state === ContentHub.ContentTransfer.Charged) {
                var urls = []
                for(var i=0; i < transfer.items.length; i++) {
                    urls.push(transfer.items[i].url)
                }
                pageStack.importContactRequested(urls)
            }
        }
    }
}
