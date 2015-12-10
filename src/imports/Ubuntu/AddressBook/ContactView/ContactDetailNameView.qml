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
import Ubuntu.Components 1.3
import QtContacts 5.0

import Ubuntu.AddressBook.Base 0.1

ContactDetailBase {
    id: root

    detail: root.contact ? root.contact.name : null
    implicitHeight: label.paintedHeight + (label.anchors.margins * 2)
    activeFocusOnTab: false

    Label {
        id: label

        function formatNameToDisplay(contact) {
            if (!contact) {
                return ""
            }

            if (contact.name) {
                var detail = contact.name
                return detail.firstName + " " + detail.lastName
            } else if (contact.displayLabel && contact.displayLabel.label && contact.displayLabel.label !== "") {
                return contact.displayLabel.label
            } else {
                return ""
            }
        }

        anchors {
            fill: parent
            margins: units.gu(2)
        }
        fontSize: "x-large"
        elide: Text.ElideRight
        color: Qt.rgba(0.4, 0.4, 0.4, 1.0)
        style: Text.Raised
        styleColor: "white"
        text: formatNameToDisplay(root.contact)
    }
}
