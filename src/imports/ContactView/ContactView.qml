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
import Ubuntu.Contacts 0.1 as ContactsUI
import Ubuntu.Components.Popups 0.1 as Popups

Page {
    id: root
    objectName: "contactViewPage"

    property QtObject contact: null
    property alias model: contactFetch.model
    // used by main page to open the contact view on app startup
    property string contactId: ""
    property string addPhoneToContact: ""

    function formatNameToDisplay(contact) {
        if (!contact) {
            return ""
        }
        if (contact.name) {
            var detail = contact.name
            return detail.firstName +" " + detail.lastName
        } else if (contact.displayLabel && contact.displayLabel.label && contact.displayLabel.label !== "") {
            return contact.displayLabel.label
        } else {
            return ""
        }
    }

    title: formatNameToDisplay(contact)
    onActiveChanged: {
        if (active) {
            //WORKAROUND: to correct scroll back the page
            flickable.returnToBounds()
        }
    }

    // Page page if the contact get removed
    onContactChanged: {
        if (!contact) {
            pageStack.pop()
        }
    }

    Flickable {
        id: flickable

        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        //WORKAROUND: There is a bug on SDK page that causes the page to appear flicked with small contents
        // see bug #1223050
        contentHeight: Math.max(contents.height, parent.height)
        contentWidth: parent.width
        visible: !busyIndicator.visible

        Column {
            id: contents

            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ContactDetailAvatarView {
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
            }

            ContactDetailEmailsView {
                objectName: "emails"

                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOnlineAccountsView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailAddressesView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOrganizationsView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailSyncTargetView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }
        }
    }

    ActivityIndicator {
        id: busyIndicator

        running: (root.contact === null) && contactFetch.running
        visible: running
        anchors.centerIn: parent
    }

    ContactFetchError {
        id: fetchErrorDialog
    }

    ContactsUI.ContactFetch {
        id: contactFetch

        onContactRemoved: {
            pageStack.pop()
        }

        onContactNotFound: Popups.PopupUtils.open(fetchErrorDialog, pageStack)

        onContactFetched: {
            root.contact = contact
            if (root.addPhoneToContact != "") {
                var detailSourceTemplate = "import QtContacts 5.0; PhoneNumber{ number: \"" + root.addPhoneToContact + "\" }"
                var newDetail = Qt.createQmlObject(detailSourceTemplate, root.contact)
                if (newDetail) {
                    root.contact.addDetail(newDetail)
                    pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   { model: root.model,
                                     contact: root.contact,
                                     initialFocusSection: "phones",
                                     newDetails: [newDetail]})
                    root.addPhoneToContact = ""
                }
            }
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: Action {
                objectName: "favorite"
                text: i18n.tr("Favorite")
                iconName: root.contact && root.contact.favorite.favorite ? "favorite-selected" : "favorite-unselected"
                onTriggered: {
                    root.contact.favorite.favorite = !root.contact.favorite.favorite
                    root.contact.save()
                }
            }
        }
        ToolbarButton {
            action: Action {
                objectName: "share"
                text: i18n.tr("Share")
                iconName: "share"
                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("../ContactShare/ContactSharePage.qml"),
                                   { contactModel: root.model, contact: root.contact})
                }
            }
        }
        ToolbarButton {
            action: Action {
                objectName: "edit"
                text: i18n.tr("Edit")
                iconSource: "artwork:/edit.png"
                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   { model: root.model, contact: root.contact})
                }
            }
        }
    }

    // This will load the contact information when the app was launched with
    // the URI: addressbook:///contact?id=<id>
    Component.onCompleted: {
        if (contactId !== "") {
            contactFetch.fetchContact(contactId)
        }
    }
}
