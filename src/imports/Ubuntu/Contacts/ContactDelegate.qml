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
import Ubuntu.Components.ListItems 1.3 as ListItem
import "Contacts.js" as ContactsJS

ListItemWithActions {
    id: root

    property bool showAvatar: true
    property bool isCurrentItem: false
    property string defaultAvatarUrl: ""
    property bool flicking: false
    readonly property string displayLabel: contact ? ContactsJS.formatToDisplay(contact, "") : ""

    signal clicked(int index, QtObject contact)
    signal pressAndHold(int index, QtObject contact)

    implicitHeight: defaultHeight
    width: parent ? parent.width : 0

    onItemClicked: root.clicked(index, contact)
    onItemPressAndHold: root.pressAndHold(index, contact)
    onFlickingChanged: {
        if (flicking) {
            resetSwipe()
        }
    }

    Item {
        id: delegate

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(6)

        ContactAvatar {
            id: avatar

            contactElement: contact
            fallbackDisplayName: root.displayLabel
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: root.showAvatar ? height : 0
            visible: width > 0
        }

        Label {
            id: name
            objectName: "nameLabel"

            anchors {
                left: avatar.right
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            color: theme.palette.normal.backgroundText
            text: root.displayLabel != "" ? root.displayLabel : i18n.dtr("address-book-app", "No name")
            elide: Text.ElideRight
        }
    }
}
