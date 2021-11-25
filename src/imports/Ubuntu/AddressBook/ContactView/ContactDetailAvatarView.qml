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
import QtGraphicalEffects 1.0
import QtContacts 5.0
import Ubuntu.Components 1.3

import Ubuntu.Contacts 0.1
import Ubuntu.AddressBook.Base 0.1

ContactDetailBase {
    id: root

    property alias editable: favImage.enabled
    property var constituents: []

    implicitHeight: units.gu(12)
    implicitWidth: parent.width
    activeFocusOnTab: false

    Connections {
        id: connections

        target: avatar.contactElement
        ignoreUnknownSignals: true
        onContactChanged: avatar.reload()
    }

    Image {
        id: imageBg

        source: avatar.avatarUrl
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        visible: false
        asynchronous: true

        OpacityMask {
            source: mask
            maskSource: imageBg
        }

        LinearGradient {
            id: mask
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(imageBg.x + imageBg.width, 0)
            gradient: Gradient {
                GradientStop { position: 0.2; color: "transparent"}
                GradientStop { position: 1.0; color: theme.palette.normal.background }
            }
        }

    }

    FastBlur {
        anchors.fill: imageBg
        source: imageBg
        radius: 32
        visible: avatar.avatarUrl !== avatar.fallbackAvatarUrl
    }

    ContactAvatar {
        id: avatar
        objectName: "contactAvatarDetail"

        contactElement: root.contact
        height: units.gu(8)
        width: height

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: units.gu(2)
        }

    }

    ActionButton {
        id: favImage
        objectName: "contactFavoriteDetail"

        iconName: root.contact && root.contact.favorite.favorite ? "starred" : "non-starred"
        height: units.gu(4)
        visible: root.editable || (root.contact && root.contact.favorite.favorite)
        iconSize: units.gu(3)
        width: height
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        onClicked: {
            for (var i = 0; i < constituents.length; i++) {
                var constituent = constituents[i]
                constituent.favorite.favorite = !root.contact.favorite.favorite
                constituent.save()
            }
        }
    }
}
