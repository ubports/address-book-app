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
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Contacts 0.1 as ContactsUI

import "../Common"

ContactDetailBase {
    id: root

    implicitHeight: units.gu(8)
    implicitWidth: units.gu(10)

    Connections {
        id: connections

        function updateTarget()
        {
            if (root.contact) {
                var avatarDetail = root.contact.detail(ContactDetail.Avatar)
                if (avatarDetail) {
                    return avatarDetail
                } else  {
                    return root.contact
                }
            }
            return null
        }

        target: updateTarget()
        ignoreUnknownSignals: true
        onContactChanged: {
            var avatarDetail = root.contact.detail(ContactDetail.Avatar)
            if (avatarDetail) {
                avatar.reload()
                connections.target = avatarDetail
            }
        }
        onDetailChanged: {
            var avatarDetail = root.contact.detail(ContactDetail.Avatar)
            if (avatarDetail === null) {
                connections.target = root.contact
            }
            avatar.reload()
        }
    }

    ContactsUI.ContactAvatar {
        id: avatar

        contactElement: root.contact
        anchors {
            fill: parent
            leftMargin: units.gu(2)
        }
    }
}
