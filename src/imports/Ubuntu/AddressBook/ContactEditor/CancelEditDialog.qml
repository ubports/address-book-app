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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3 as Popups

Popups.Dialog {
    id: cancelEditDialog

    title: i18n.tr("Discard contact changes")

    signal discardClicked()
    signal keepEditingClicked()

    Button {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
        text: i18n.dtr("address-book-app", "Keep editing")
        color: UbuntuColors.green
        onClicked: keepEditingClicked()
    }

    Button {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
        text: i18n.dtr("address-book-app", "Discard changes")
        color: UbuntuColors.red
        onClicked: discardClicked()
    }
}
