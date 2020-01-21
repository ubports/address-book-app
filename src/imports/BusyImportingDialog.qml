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
import Ubuntu.Components.Popups 1.3 as Popups

import Ubuntu.AddressBook.Base 0.1

Popups.Dialog {
    id: busyImportingDialog

    property alias allowToClose: closeButton.visible
    property alias showActivity: busyIndicator.visible
    signal destruction

    title: i18n.tr("Importing...")

    ActivityIndicator {
        id: busyIndicator
        running: visible
        visible: true
    }
    Button {
        id: closeButton
        text: i18n.tr("Cancel")
        visible: false
        color: theme.palette.normal.negative
        onClicked: {
            busyImportingDialog.destruction()
            PopupUtils.close(busyImportingDialog)
        }
    }
}
