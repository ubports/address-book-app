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
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import "Contacts.js" as ContactsJS

ListItemWithActions {
    id: root

    property bool showAvatar: true
    property bool isCurrentItem: false
    property string defaultAvatarUrl: ""
    property string defaultTitle: ""
    property int titleDetail: ContactDetail.Name
    property variant titleFields: [ Name.FirstName, Name.LastName ]
    property bool detailsShown: false
    property int loaderOpacity: 0.0
    property bool flicking: false

    signal clicked(int index, QtObject contact)
    signal pressAndHold(int index, QtObject contact)
    signal detailClicked(QtObject contact, QtObject detail, string action)
    signal infoRequested(int index, QtObject contact)
    signal addContactClicked(string label)
    signal addDetailClicked(QtObject contact, int detailType)

    function _onDetailClicked(detail, action)
    {
        detailClicked(contact, detail, action)
    }

    function _onAddDetailClicked(detail, detailType)
    {
        addDetailClicked(contact, detailType)
    }

    implicitHeight: defaultHeight + (pickerLoader.item ? pickerLoader.item.height : 0)
    width: parent ? parent.width : 0

    onItemClicked: root.clicked(index, contact)
    onItemPressAndHold: root.pressAndHold(index, contact)

    Item {
        id: delegate

        anchors {
            left: parent.left
            right: parent.right
        }
        height: units.gu(6)

        Rectangle {
            anchors {
                fill: parent
                leftMargin: units.gu(-2)
                rightMargin: units.gu(-2)
                topMargin: units.gu(-1)
                bottomMargin: units.gu(-1)
            }
            color: "#E6E6E6"
            opacity: root.detailsShown ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation { }
            }
        }

        ContactAvatar {
            id: avatar

            contactElement: contact
            fallbackDisplayName: name.text
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

            anchors {
                left: avatar.right
                leftMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: infoIcon.anchors.rightMargin + infoIcon.height

            }
            color: UbuntuColors.lightAubergine
            text: contact ? ContactsJS.formatToDisplay(contact, root.titleDetail, root.titleFields, "") : root.defaultTitle
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
                onClicked: {
                    if (contact) {
                        root.infoRequested(index, contact)
                    } else {
                        root.addContactClicked(name.text)
                    }
                }
            }
        }

    }

    Loader {
        id: pickerLoader

        source: {
            if (!root.detailsShown) {
                return "";
            }

            switch(root.detailToPick) {
            case ContactDetail.PhoneNumber:
            default:
                return Qt.resolvedUrl("ContactDetailPickerPhoneNumberDelegate.qml")
            }
        }
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
                pickerLoader.item.updateDetails(contact)
                pickerLoader.item.detailClicked.connect(root._onDetailClicked)
                pickerLoader.item.addDetailClicked.connect(root._onAddDetailClicked)
            }
        }

        // update delegate if contact update
        Connections {
            target: contact
            onContactChanged: {
                if (pickerLoader.item) {
                    pickerLoader.item.updateDetails(contact)
                }
            }
        }
    }

    Behavior on height {
        id: behaviorOnHeight

        property bool active: false

        enabled: active && !root.flicking
        UbuntuNumberAnimation { }
    }

    state: isCurrentItem ? "expanded" : ""
    states: [
        State {
            name: "expanded"
            PropertyChanges {
                target: root
                clip: true
                height: root.implicitHeight
                loaderOpacity: 1.0
                locked: true
                // FIXME: Setting detailsShown to true on expanded state cause the property to change to false and true during the state transition, and that
                // causes the loader to load twice
                //detailsShown: true
            }
            PropertyChanges {
                target: behaviorOnHeight
                active: true
            }
        }
    ]
    transitions: [
        Transition {
            from: "expanded"
            to: ""
            SequentialAnimation {
                UbuntuNumberAnimation {
                    target: root
                    properties: "height,loaderOpacity"
                    duration: root.flicking ? 0 : UbuntuAnimation.FastDuration
                }
                PropertyAction {
                    target: root
                    property: "clip"
                }
                PropertyAction {
                    target: root
                    property: "detailsShown"
                    value: false
                }
                PropertyAction {
                    target: root
                    property: "ListView.delayRemove"
                    value: false
                }
            }
        },
        Transition {
            from: ""
            to: "expanded"
            SequentialAnimation {
                PropertyAction {
                    target: root
                    properties: "detailsShown"
                    value: true
                }
                PropertyAction {
                    target: root
                    properties: "ListView.delayRemove"
                    value: true
                }

            }
        }
    ]
}
