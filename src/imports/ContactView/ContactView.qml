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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0 as Popups
import Ubuntu.Contacts 0.1

ContactPreviewPage {
    id: root
    objectName: "contactViewPage"

    property alias model: contactFetch.model
    // used by main page to open the contact view on app startup
    property string contactId: ""
    property string addPhoneToContact: ""

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

    extensions: ContactDetailSyncTargetView {
        contact: root.contact
        anchors {
            left: parent.left
            right: parent.right
        }
        height: implicitHeight
    }

    ActivityIndicator {
        id: busyIndicator

        parent: root

        running: (root.contact === null) && contactFetch.running
        visible: running
        anchors.centerIn: parent
    }

    ContactFetchError {
        id: fetchErrorDialog
    }

    ContactFetch {
        id: contactFetch

        onContactRemoved: {
            pageStack.pop()
        }

        onContactNotFound: Popups.PopupUtils.open(fetchErrorDialog, pageStack)

        onContactFetched: {
            root.contact = contact
            if (root.addPhoneToContact != "") {
                var detailSourceTemplate = "import QtContacts 5.0; PhoneNumber{ number: \"" + root.addPhoneToContact.trim() + "\" }"
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

    head.actions: [
        Action {
            objectName: "share"
            text: i18n.tr("Share")
            iconName: "share"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../ContactShare/ContactSharePage.qml"),
                               { contactModel: root.model, contacts: [root.contact] })
            }
        },
        Action {
            objectName: "edit"
            text: i18n.tr("Edit")
            iconName: "edit"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                               { model: root.model, contact: root.contact})
            }
        }
    ]

    // This will load the contact information when the app was launched with
    // the URI: addressbook:///contact?id=<id>
    Component.onCompleted: {
        if (contactId !== "") {
            contactFetch.fetchContact(contactId)
        }
    }
}
