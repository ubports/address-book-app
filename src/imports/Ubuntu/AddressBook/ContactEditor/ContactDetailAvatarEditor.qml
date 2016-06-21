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
import QtContacts 5.0

import Ubuntu.Components 1.3

import Ubuntu.Contacts 0.1
import Ubuntu.AddressBook.Base 0.1

ContactDetailBase {
    id: root

    readonly property alias busy: activityIndicator.running
    readonly property string defaultAvatar: "image://theme/add"
    property string temporaryAvatar: ""
    property string temporaryAvatarId: ""

    function isEmpty() {
        return false;
    }

    function save() {
        // create the avatar detail
        if (avatarImage.source != root.defaultAvatar) {
            if (root.detail && (root.detail.imageUrl === avatarImage.source)) {
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
            if (avatarValue && (avatarValue != "")) {
                avatarUrl = avatarValue
            }
        }
        return avatarUrl
    }

    detail: contact ? contact.detail(ContactDetail.Avatar) : null
    implicitHeight: units.gu(8)
    implicitWidth: units.gu(8)
    highlightOnFocus: false

    UbuntuShape {
        id: avatar

        radius: "medium"
        anchors.fill: parent
        source: avatarImage.source != defaultAvatar ? avatarImage : null
        sourceFillMode: UbuntuShape.PreserveAspectCrop

        Image {
            id: avatarImage
            objectName: "avatarImage"

            asynchronous: true
            source: root.getAvatar(root.detail)
            anchors.centerIn: visible ? avatar : undefined
            height: units.gu(3)
            width: units.gu(3)
            visible: source == defaultAvatar
            sourceSize {
                width: avatarImage.visible ? units.gu(3) : avatar.width
                height: avatarImage.visible ? units.gu(3) : avatar.height
            }

            // When updating the avatar using the content picker the temporary file returned
            // can contain the same name as the previous one and if the cache is enabled this
            // will cause the image to not be updated
            cache: false
        }
    }

    ActivityIndicator {
        id: activityIndicator

        anchors.centerIn: avatar
        running: (avatarImport.importDialog != null) || (root.temporaryAvatarId != "")
        visible: running
    }

    AvatarImport {
        id: avatarImport

        onAvatarReceived: {
            Contacts.removeFile(root.temporaryAvatar)

            // remove the previous image, this is nessary to make sure that the new image
            // get updated otherwise if the new image has the same name the image will not
            // be updated
            avatarImage.source = ""
            // copy and resize image
            root.temporaryAvatarId = Contacts.copyImage(avatarUrl, null);
        }
    }

    Connections {
        target: Contacts
        onImageCopyDone: {
            if (root.temporaryAvatarId === id) {
                root.temporaryAvatar = fileName
                avatarImage.source = fileName
                root.temporaryAvatarId = ""
            }
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

    Component.onDestruction: {
        root.temporaryAvatar = ""
    }
}
