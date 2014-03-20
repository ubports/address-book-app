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

import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1

import "../Common"

ContactDetailBase {
    id: root

    readonly property string defaultAvatar: Qt.resolvedUrl("../../artwork/contact-default-profile.png")

    function getAvatar(avatarDetail)
    {
        // use this verbose mode to avoid problems with binding loops
        var avatarUrl = defaultAvatar
        if (avatarDetail) {
            var avatarValue = avatarDetail.value(Avatar.ImageUrl)
            if (avatarValue != "") {
                avatarUrl = avatarValue
            }
        }
        return avatarUrl
    }

    detail: contact ? contact.detail(ContactDetail.Avatar) : null
    implicitHeight: units.gu(17)

    // update the contact detail in case of the contact change
    Connections {
        target: root.contact
        onContactChanged: {
            if (root.contact)
                root.detail = contact.detail(ContactDetail.Avatar)
            else
                root.detail = null
        }
    }

    // avoid change the avatar if the contact detail changes but the value still the same
    onDetailChanged: {
        if (detail && contact) {
            var newAvatar = root.getAvatar(root.detail)
            if (newAvatar != avatar.source) {
                avatar.source = newAvatar
            }
        } else {
            avatar.source = root.defaultAvatar
        }
    }

    Image {
        id: avatar

        anchors.fill: parent
        asynchronous: true
        smooth: true
        source: root.defaultAvatar
        fillMode: Image.PreserveAspectCrop
    }
}
