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
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1 as Popups

Item {
    id: root

    property alias model: modelConnections.target
    property var vcards: []

    property var _importedVcards: []
    property var _importErrors: []

    signal finished()

    function importContacts(vcards)
    {
        root.vcards = vcards
        for(var i=0, iMax=vcards.length; i < iMax; i++) {
            model.importContacts(vcards[i])
        }
    }

    Connections {
        id: modelConnections

        onImportCompleted: {
            var imported = root._importedVcards
            var importErrors = root._importErrors
            imported.push(url)
            if (error !== ContactModel.ImportNoError) {
                root._importErrors.push(error)
            }
            root._importedVcards = imported
            root._importErrors = importErrors
        }
    }


    Popups.Dialog {
        id: dialog

        title: i18n.tr("Import vCards")
        text: root._importedVcards.length === 0 ? i18n.tr("Importing...") : i18n.tr("%1 vCards imported").arg(root._importedVcards.length)

        Button {
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(1)
            }
            text: i18n.tr("Close")
            onClicked: root.finished()
        }
    }

    Component.onCompleted: {
        var dialog = PopupUtils.open(dialog, null)
    }
}



