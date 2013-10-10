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
import Ubuntu.Components.ListItems 0.1 as ListItem
import "Contacts.js" as ContactsJS

Item {
   id: item

   property int index: -1
   property bool showAvatar: true
   property alias selected: delegate.selected
   property alias removable: delegate.removable
   property bool selectMode: false
   property string defaultAvatarUrl: ""
   property int titleDetail: ContactDetail.Name
   property variant titleFields: [ Name.FirstName, Name.LastName ]
   property bool detailsShown: false

   signal contactClicked(var index, var contact)
   signal pressAndHold(var index, var contact)

   implicitHeight: delegate.height + (item.detailsShown ? pickerLoader.item.height : 0)
   width: parent ? parent.width : 0
   clip: true

    ListItem.Empty {
        id: delegate

        height: units.gu(6)
        showDivider: false
        confirmRemoval: removable
        UbuntuShape {
            id: avatar

            height: units.gu(4)
            width: item.showAvatar ? units.gu(4) : 0
            visible: width > 0
            radius: "medium"
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            image: Image {
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                source: ContactsJS.getAvatar(contact, item.defaultAvatarUrl)
            }
        }

        Label {
            id: name

            anchors {
                left: avatar.right
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
                right: selectionMark.left
            }

            height: paintedHeight
            text: ContactsJS.formatToDisplay(contact, item.titleDetail, item.titleFields)
            fontSize: "medium"
        }

        Rectangle {
            id: selectionMark

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }

            color: "black"
            width: item.selectMode ? units.gu(5) : 0
            visible: width > 0

            Behavior on width {
                UbuntuNumberAnimation { }
            }

            Image {
                height: units.gu(3)
                width: height
                anchors.centerIn: parent
                source: Qt.resolvedUrl("./artwork/tick-dark.png")
                opacity: item.selected ? 1.0 : 0.2
            }
        }

        onClicked: item.contactClicked(index, contact)
        onPressAndHold: item.pressAndHold(index, contact)

        onItemRemoved: {
            contactsModel.removeContact(contact.contactId)
        }
    }

    Loader {
        id: pickerLoader

        source: item.detailsShown ? Qt.resolvedUrl("ContactDetailPickerDelegate.qml") : ""
        anchors {
            top: delegate.bottom
            left: parent.left
            right: parent.right
        }
        onStatusChanged: {
            if (status == Loader.Ready) {
                pickerLoader.item.contactsModel = contactsModel
                pickerLoader.item.detailType = detailToPick
                pickerLoader.item.contactId = contact.contactId
            }
        }
    }

    ListItem.ThinDivider {
        anchors {
            bottom: pickerLoader.bottom
            right: parent.right
            left: parent.left
        }
    }

    Connections {
        target: pickerLoader.item
        onDetailClicked: detailClicked(contact, detail)
    }
}
