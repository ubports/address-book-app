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
import Ubuntu.Contacts 0.1
import "Contacts.js" as ContactsJS

UbuntuShape {
    id: avatar

    property var contactElement: null
    property string fallbackAvatarUrl: "image://theme/stock_contact"
    property string fallbackDisplayName: ""
    property bool showAvatarPicture: (avatarUrl != fallbackAvatarUrl) || (initials.length === 0)

    readonly property alias initials: initialsLabel.text
    readonly property string displayName: ContactsJS.formatToDisplay(contactElement, ContactDetail.Name, [Name.FirstName, Name.LastName], fallbackDisplayName)
    readonly property alias avatarUrl: img.avatarUrl

    // this is necessary because the object does not monitor changes on avatarDetail object this will be very expesive and only happens in few cases,
    // this need to be called manually on these cases
    function reload()
    {
        img.avatarUrl = Qt.binding(function() { return ContactsJS.getAvatar(contactElement, fallbackAvatarUrl) })
    }

    radius: "medium"
    color: Theme.palette.normal.overlay

    Label {
        id: initialsLabel
        objectName: "avatarInitials"

        anchors.centerIn: parent
        text: Contacts.contactInitialsFromString(displayName)
        font.pointSize: 88
        color: UbuntuColors.lightAubergine
        visible: (img.status != Image.Ready)
    }

    image: !img.visible ? img : null

    Image {
        id: img
        objectName: "avatarImage"

        property string avatarUrl: ContactsJS.getAvatar(contactElement, fallbackAvatarUrl)

        anchors.centerIn: visible ? avatar : undefined
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        source: avatar.showAvatarPicture ? avatar.avatarUrl : ""
        height: visible ? units.gu(3) : avatar.height
        width: height
        visible: avatar.avatarUrl.indexOf("image://theme/") === 0
    }
}
