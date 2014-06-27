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
import "Contacts.js" as ContactsJS

UbuntuShape {
    id: avatar

    property var contactElement: null
    property string displayName: ContactsJS.formatToDisplay(contactElement, ContactDetail.Name, [Name.FirstName, Name.LastName])
    readonly property string defaultAvatar: "image://theme/contact"
    readonly property string avatarUrl: ContactsJS.getAvatar(contactElement, "")
    readonly property bool useDefaultAvatar: (contactElement == null) || (displayName === "" || contactElement.tag.tag === "") && (avatarUrl === "")

    function reload()
    {
        img.source = ContactsJS.getAvatar(contactElement, "")
    }

    radius: "medium"
    color: Theme.palette.normal.overlay

    Label {
         anchors.centerIn: parent
         text: ContactsJS.getNameItials(displayName)
         font.pointSize: 88
         color: UbuntuColors.lightAubergine
         visible: (img.status != Image.Ready)
    }

    image: Image {
        id: img

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        source: avatar.useDefaultAvatar ? avatar.defaultAvatar : avatar.avatarUrl
        height: avatar.height
        width: avatar.width
    }
}
