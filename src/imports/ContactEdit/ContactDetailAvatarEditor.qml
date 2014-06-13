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
import Ubuntu.Components 0.1
import QtContacts 5.0

import "../Common"

ContactDetailBase {
    id: root

    readonly property string defaultAvatar: "image://theme/contact"

    function isEmpty() {
        return false;
    }

    function save() {
        if (avatarImage.source != root.defaultAvatar) {
            if (root.detail && (root.detail === avatarImage.source)) {
                return false
            } else {
                // create the avatar detail
                if (!root.detail) {
                    root.detail = root.contact.avatar
                }
                root.detail.imageUrl = avatarImage.source
                return true
            }
        }
        return false
    }

    function getAvatar(avatarDetail)
    {
        // use this verbose mode to avoid problems with binding loops
        var avatarUrl = root.defaultAvatar

        if (avatarDetail) {
            var avatarValue = avatarDetail.value(Avatar.ImageUrl)
            if (avatarValue != "") {
                avatarUrl = avatarValue
            }
        }
        return avatarUrl
    }

    detail: contact ? contact.detail(ContactDetail.Avatar) : null
    implicitHeight: units.gu(8)
    implicitWidth: units.gu(8)

    UbuntuShape {
        id: avatar

        radius: "medium"
        anchors.fill: parent
        image: Image {
            id: avatarImage

            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            source: root.getAvatar(root.detail)
            height: units.gu(8)
            width: units.gu(8)

            // When updating the avatar using the content picker the temporary file returned
            // can contain the same name as the previous one and if the cache is enabled this
            // will cause the image to not be updated
            cache: false
        }
    }

    AvatarImport {
        id: avatarImport

        onAvatarReceived: {
            // remove the previous image, this is nessary to make sure that the new image
            // get updated otherwise if the new image has the same name the image will not
            // be updated
            avatarImage.source = ""
            // Update with the new value
            avatarImage.source = application.copyImage(root.contact, avatarUrl);
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // make sure the OSK disappear
            root.forceActiveFocus()
            avatarImport.requestNewAvatar()
        }
    }
}


