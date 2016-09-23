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
import Ubuntu.Components.Popups 1.3
import Ubuntu.Contacts 0.1

Page {
    id: root

    property QtObject contact: null
    property string contactId
    property alias extensions: extensionsContents.children
    property alias model: contactFetch.model
    property alias editable: contactDetailAvatar.editable
    property alias headerActions: trailingBar.actions

    signal contactFetched(QtObject contact)
    signal contactRemoved()
    signal actionTrigerred(string action, QtObject contact, QtObject detail)

    function fetchContact(contactId)
    {
        if (contactId !== "") {
            contactFetch.fetchContact(contactId)
        }
    }

    header: PageHeader {
        id: pageHeader

        flickable: flickable
        title: contact ? ContactsJS.formatToDisplay(contact, i18n.dtr("address-book-app", "No name")) : ""
        trailingActionBar {
            id: trailingBar
        }
    }

    Connections {
        target: contact
        onContactChanged: {
            pageHeader.title = ContactsJS.formatToDisplay(contact, i18n.dtr("address-book-app", "No name"))
        }
    }

    // Pop page if the contact get removed
    onContactChanged: {
        if (!contact) {
            root.contactRemoved()
        }
    }

    onActiveChanged: {
        if (active) {
            //WORKAROUND: to correct scroll back the page
            flickable.returnToBounds()
        }
    }

    ActivityIndicator {
        id: busyIndicator

        parent: root
        running: (root.contact === null) && contactFetch.running
        visible: running
        anchors.centerIn: parent
    }

    ContactFetch {
        id: contactFetch

        onContactRemoved: root.contactRemoved()
        onContactNotFound: PopupUtils.open(Qt.resolvedUrl("ContactFetchError.qml"), root)
        onContactFetched: {
            root.contact = contact
            root.contactFetched(root.contact)
        }
    }


    Flickable {
        id: flickable

        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        clip: true
        //WORKAROUND: There is a bug on SDK page that causes the page to appear flicked with small contents
        // see bug #1223050
        contentHeight: Math.max(contents.height, parent.height) + units.gu(2)
        contentWidth: parent.width

        Column {
            id: contents

            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ContactDetailAvatarView {
                id: contactDetailAvatar
                objectName: "avatar"

                contact: root.contact
                anchors.left: parent.left
                height: implicitHeight
                width: implicitWidth
            }

            ContactDetailPhoneNumbersView {
                objectName: "phones"

                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                onActionTrigerred: root.actionTrigerred(actionName, root.contact, detail)
            }

            ContactDetailEmailsView {
                objectName: "emails"

                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                onActionTrigerred: root.actionTrigerred(actionName, root.contact, detail)
            }

            ContactDetailOnlineAccountsView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                onActionTrigerred: root.actionTrigerred(actionName, root.contact, detail)
            }

            ContactDetailAddressesView {
                objectName: "addresses"

                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                onActionTrigerred: root.actionTrigerred(actionName, root.contact, detail)
            }

            ContactDetailOrganizationsView {
                objectName: "organizations"

                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                onActionTrigerred: root.actionTrigerred(actionName, root.contact, detail)
            }

            Item {
                id: extensionsContents

                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: childrenRect.height
            }
        }
    }

    Component.onCompleted: {
        if (contact == null) {
            fetchContact(root.contactId)
        }
    }
    onContactIdChanged: {
        if (contact == null) {
            fetchContact(root.contactId)
        }
    }
    onModelChanged: {
        if (contact == null) {
            fetchContact(root.contactId)
        }
    }
}
