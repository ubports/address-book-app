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

UbuntuShape {
    id: img

    property var contact: model ? model.contact : null

    signal clicked(string contactId)

    image: Image {
        fillMode: Image.PreserveAspectCrop
        source: img.contact.avatar && (img.contact.avatar.imageUrl != "") ?
                    Qt.resolvedUrl(img.contact.avatar.imageUrl) :
                    "artwork:/avatar-default.png"
        asynchronous: true
    }

    Rectangle {
        id: bgLabel

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(5)
        color: "black"
        opacity: 0.7
    }

    Label {
        id: contactName

        anchors {
            left: bgLabel.left
            leftMargin: units.gu(1.0)
            top: bgLabel.top
            topMargin: units.gu(0.5)
            right: bgLabel.right
        }
        height: units.gu(2.5)
        verticalAlignment: Text.AlignVCenter
        text: contact.name ? contact.name.firstName + " " + contact.name.lastName : ""
        elide: Text.ElideRight
        color: "white"
    }

    Label {
        id: contactPhoneLabel

        anchors {
            left: contactName.left
            top: contactName.bottom
            right: contactName.right
        }
        height: units.gu(1)
        verticalAlignment:  Text.AlignVCenter
        text: contact.phoneNumber.number
        elide: Text.ElideRight
        fontSize: "small"
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: img.clicked(contact.contactId)
    }
}
