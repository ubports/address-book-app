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
   property variant itemDelegate: null

   implicitHeight: delegate.height + (delegate.detailsShown ? pickerLoader.item.height : 0)
   width: parent ? parent.width : 0
   clip: true

    Connections {
        target: contactListView
        onCurrentContactExpandedChanged: {
            if (index != currentContactExpanded) {
                delegate.detailsShown = false
            }
        }
    }

    ListItem.Empty {
        id: delegate

        property bool detailsShown: false

        height: units.gu(6)
        showDivider: false
        selected: contactListView.multiSelectionEnabled &&
                  item.itemDelegate &&
                  contactListView.isSelected &&
                  contactListView.isSelected(item.itemDelegate)
        removable: contactListView &&
                   contactListView.swipeToDelete &&
                   !detailsShown &&
                   !contactListView.isInSelectionMode

        UbuntuShape {
            id: avatar

            height: units.gu(4)
            width: contactListView.showAvatar ? units.gu(4) : 0
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
                source: ContactsJS.getAvatar(contact)
            }
        }

        Row {
            spacing: units.gu(1)
            anchors {
                left: avatar.right
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
                right: selectionMark.left
            }
            Label {
                id: name
                height: paintedHeight
                text: ContactsJS.formatToDisplay(contact, contactListView.titleDetail, contactListView.titleFields)
                fontSize: "medium"
            }
//            Label {
//                id: company
//                height: paintedHeight
//                text: ContactsJS.formatToDisplay(contact, contactListView.subTitleDetail, contactListView.subTitleFields)
//                fontSize: "medium"
//                opacity: 0.2
//            }
        }

        Rectangle {
            id: selectionMark

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }

            color: "black"
            width: delegate.selected ? units.gu(5) : 0
            visible: width > 0
            Icon {
                name: "select"
                height: units.gu(3)
                width: height
                anchors.centerIn: parent
            }
        }

        onClicked: {
            if (contactListView.isInSelectionMode) {
                if (!contactListView.selectItem(item.itemDelegate)) {
                    contactListView.deselectItem(item.itemDelegate)
                }
                return
            }
            if (currentContactExpanded == index) {
                currentContactExpanded = -1
                detailsShown = false
                return
            // check if we should expand and display the details picker
            } else if (detailToPick !== 0){
                currentContactExpanded = index
                detailsShown = !detailsShown
                return
            }
            if (priv.currentOperation !== -1) {
                return
            }
            contactListView.currentIndex = index
            priv.currentOperation = contactsModel.fetchContacts(contact.contactId)
        }

        onPressAndHold: {
            if (contactListView.multiSelectionEnabled) {
                contactListView.startSelection()
                contactListView.selectItem(itemDelegate)
            }
        }

        onItemRemoved: {
            contactsModel.removeContact(contact.contactId)
        }

        backgroundIndicator: Rectangle {
            anchors.fill: parent
            color: Theme.palette.selected.base
            Label {
                text: "Delete"
                anchors {
                    fill: parent
                    margins: units.gu(2)
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment:  delegate.swipingState === "SwipingLeft" ? Text.AlignLeft : Text.AlignRight
            }
        }
    }

    Loader {
        id: pickerLoader

        source: delegate.detailsShown ? Qt.resolvedUrl("ContactDetailPickerDelegate.qml") : ""
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
