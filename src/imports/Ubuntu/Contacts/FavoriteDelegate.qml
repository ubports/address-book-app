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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtContacts 5.0
import "Contacts.js" as ContactsJS

ListItem.Empty {
    id: favoriteItem

    property int index: -1
    property bool showAvatar: true
    property string defaultAvatarUrl: ""
    property int titleDetail: ContactDetail.Name
    property variant titleFields: [ Name.FirstName, Name.LastName ]
    property bool showPhoneLabel: true

    signal contactClicked(var index, var contact)

    implicitHeight: units.gu(8)
    width: parent ? parent.width : 0

    Rectangle {
        anchors {
            fill: parent
            bottomMargin: units.dp(1)
        }
        color: UbuntuColors.warmGrey
        opacity: 0.07
    }

    UbuntuShape {
        id: avatar

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(1)
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }
        width: favoriteItem.showAvatar ? height : 0
        visible: favoriteItem.showAvatar
        radius: "medium"
        image: Image {
            property bool isDefaultAvatar: (source == favoriteItem.defaultAvatarUrl)

            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            source: ContactsJS.getAvatar(contact, favoriteItem.defaultAvatarUrl)
            sourceSize.width: isDefaultAvatar ? undefined : width * 1.5
            sourceSize.height: isDefaultAvatar ? undefined : height * 1.5
        }
    }

    Column {
        anchors {
            top: parent.top
            topMargin:  units.gu(2)
            left: avatar.right
            leftMargin: units.gu(2)
            right: parent.right
            bottom: parent.bottom
        }

        Label {
            id: name

            anchors {
                left: parent.left
                right: parent.right
            }

            height: favoriteItem.showPhoneLabel ? paintedHeight : paintedHeight * 2
            verticalAlignment: Text.AlignVCenter
            text: ContactsJS.formatToDisplay(contact, favoriteItem.titleDetail, favoriteItem.titleFields)
            fontSize: "medium"
        }

        Label {
            id: label

            anchors {
                left: parent.left
                right: parent.right
            }

            opacity: 0.2
            height: favoriteItem.showPhoneLabel ? paintedHeight : 0
            text: favoriteItem.showPhoneLabel && contact.phoneNumbers ? ContactsJS.getFavoritePhoneLabel(contact, "") : ""
            fontSize: "medium"
        }
    }

    onClicked: favoriteItem.contactClicked(index, contact)
}
