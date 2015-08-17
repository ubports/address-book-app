/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0 as Popups

Item {
    id: root

    property alias model: modelConnections.target
    property var vcards: []
    property var importedVcards: []
    property var importErrors: []
    property var dialog: null

    signal finished()

    function importVCards(model, vcards)
    {
        if (dialog || vcards.length === 0) {
            return
        }

        root.model = model
        root.vcards = vcards
        dialog = Popups.PopupUtils.open(importDialogComponent, root)

        for(var i=0, iMax=vcards.length; i < iMax; i++) {
            var vcardUrl = vcards[i]
            model.importContacts(vcardUrl)
        }
    }

    Connections {
        id: modelConnections

        onImportCompleted: {
            var imported = root.importedVcards
            var importErrors = root.importErrors
            imported.push(url)
            if (error !== ContactModel.ImportNoError) {
                root.importErrors.push(error)
                console.error("Fail to import vcard:" + error)
            }
            root.importedVcards = imported
            root.importErrors = importErrors
        }
    }

    Component {
        id: importDialogComponent

        Popups.Dialog {
            id: importDialog

            title: i18n.tr("Import vCards")
            text: root.importedVcards.length === 0 ?  i18n.tr("Importing...") : i18n.tr("%1 vCards imported").arg(root.importedVcards.length)

            Button {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                text: i18n.tr("Close")
                enabled: (root.importedVcards.length === root.vcards.length)
                onClicked: {
                    root.dialog = null
                    Popups.PopupUtils.close(importDialog)
                }
            }

            Component.onDestruction: root.destroy()
        }
    }
}



