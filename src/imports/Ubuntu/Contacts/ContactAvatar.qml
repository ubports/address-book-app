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
import QtContacts 5.0
import Ubuntu.Components 1.3
import Ubuntu.Contacts 0.1
import "Contacts.js" as ContactsJS

UbuntuShape {
    id: avatar

    property var contactElement: null
    property string fallbackAvatarUrl: "image://theme/stock_contact"
    property string fallbackDisplayName: ""
    property bool showAvatarPicture: (avatarUrl != fallbackAvatarUrl) || (initials.length === 0)

    readonly property alias initials: initialsLabel.text
    readonly property alias displayName: initialsLabel.contactDisplayName
    readonly property alias avatarUrl: img.avatarUrl

    // this is necessary because the object does not monitor changes on avatarDetail object this will be very expesive and only happens in few cases,
    // this need to be called manually on these cases
    function reload()
    {
        img.avatarUrl = Qt.binding(function() { return ContactsJS.getAvatar(contactElement, fallbackAvatarUrl) })
        initialsLabel.contactDisplayName = Qt.binding(function() { return ContactsJS.formatToDisplayWithDetails(contactElement, ContactDetail.Name, [Name.FirstName, Name.MiddleName, Name.LastName], fallbackDisplayName) })
    }

    aspect: UbuntuShape.Flat
    radius: "medium"
    backgroundColor: ContactsJS.contactColor(displayName)

    Label {
        id: initialsLabel
        objectName: "avatarInitials"

        property string contactDisplayName: ContactsJS.formatToDisplayWithDetails(contactElement, ContactDetail.Name, [Name.FirstName, Name.MiddleName, Name.LastName], fallbackDisplayName)

        anchors.centerIn: parent
        text: Contacts.contactInitialsFromString(contactDisplayName)
        color: "white"
        visible: (img.status != Image.Ready) && !fallbackIcon.visible
        fontSize: "large"
    }

    source: !img.visible ? img : null
    sourceFillMode: UbuntuShape.PreserveAspectCrop

    Image {
        id: img
        objectName: "avatarImage"

        property string avatarUrl: ContactsJS.getAvatar(contactElement, fallbackAvatarUrl)

        asynchronous: true
        source: avatar.showAvatarPicture && (avatar.avatarUrl.indexOf("image://theme/") === -1)  ? avatar.avatarUrl : ""
        height: avatar.height
        width: height
        visible: false
        sourceSize.width: avatar.width
        sourceSize.height: avatar.height
    }

    Icon {
        id: fallbackIcon
        objectName: "fallbackIcon"

        source: visible ? img.avatarUrl : ""
        visible: avatar.showAvatarPicture && (avatar.avatarUrl.indexOf("image://theme/") === 0)
        color: "white"
        anchors.centerIn: avatar
        height: units.gu(3)
        width: height
        asynchronous: true
    }
}
