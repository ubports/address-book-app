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
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "Contacts.js" as ContactsJS

Item {
    id: root

    property bool showAvatar: true
    property bool selected: false
    property string defaultAvatarUrl: ""
    property int titleDetail: ContactDetail.Name
    property variant titleFields: [ Name.FirstName, Name.LastName ]
    property bool detailsShown: false
    property int loaderOpacity: 0.0

    signal clicked(int index, QtObject contact)
    signal pressAndHold(int index, QtObject contact)
    signal detailClicked(QtObject contact, QtObject detail, string action)
    signal infoRequested(int index, QtObject contact)

    function _onDetailClicked(detail, action)
    {
        detailClicked(contact, detail, action)
    }

    // ListItemWithActions
    //onItemClicked: root.clicked(index, contact)
    //onItemPressAndHold: root.pressAndHold(index, contact)

    height: delegate.height
    implicitHeight: delegate.height + (pickerLoader.item ? pickerLoader.item.height : 0)
    width: parent ? parent.width : 0

    Item {
        id: delegate

        height: units.gu(8)
        anchors {
            left: parent.left
            right: parent.right
        }

        Rectangle {
            id: selectionMark

            anchors.fill: parent
            color: root.selected ? "black" : Theme.palette.selected.background
            opacity: root.selected ? 0.2 : 1.0
            visible: root.selected || root.detailsShown
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.clicked(index, contact)
            onPressAndHold: root.pressAndHold(index, contact)
        }

        ContactAvatar {
            id: avatar

            contactElement: contact
            displayName: name.text
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: units.gu(1)
            }
            width: root.showAvatar ? height : 0
            visible: width > 0
        }

        Label {
            id: name

            anchors {
                left: avatar.right
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
                right: infoIcon.left
            }
            font.pointSize: 88
            color: UbuntuColors.lightAubergine
            text: ContactsJS.formatToDisplay(contact, root.titleDetail, root.titleFields)
            elide: Text.ElideRight
        }

        Icon {
            id: infoIcon
            objectName: "infoIcon"

            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }
            name: "contact"
            height: units.gu(3)
            width: opacity > 0.0 ? height : 0
            opacity: root.detailsShown ? 1.0 : 0.0
            Behavior on opacity {
                UbuntuNumberAnimation { }
            }

            MouseArea {
               anchors.fill: parent
               onClicked: root.infoRequested(index, contact)
            }
        }

    }

    Loader {
        id: pickerLoader

        source: {
            switch(root.detailToPick) {
            case ContactDetail.PhoneNumber:
            default:
                return Qt.resolvedUrl("ContactDetailPickerPhoneNumberDelegate.qml")
            }
        }
        active: root.detailsShown
        asynchronous: true
        anchors {
            top: delegate.bottom
            left: parent.left
            right: parent.right
        }

        opacity: root.loaderOpacity
        Behavior on opacity {
            UbuntuNumberAnimation { }
        }

        onStatusChanged: {
            if (status == Loader.Ready) {
                pickerLoader.item.contactsModel = listModel
                pickerLoader.item.contactId = contact.contactId
                pickerLoader.item.detailClicked.connect(root._onDetailClicked)
            }
        }
    }
}
