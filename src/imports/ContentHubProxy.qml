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
import Ubuntu.Content 1.3 as ContentHub

QtObject {
    property QtObject pageStack: null
    property list<QtObject> objects: [
        Connections {
            target: ContentHub.ContentHub
            onExportRequested: {
                // enter in pick mode
                mainWindow.pickWithTransfer((transfer.selectionType === ContentHub.ContentTransfer.Single),
                                             transfer)
            }
            onImportRequested: {
                if (transfer.state === ContentHub.ContentTransfer.Charged) {
                    var urls = []
                    for(var i=0; i < transfer.items.length; i++) {
                        urls.push(transfer.items[i].url)
                    }
                    mainWindow.importvcards(urls)
                }
            }
        }
    ]
}
