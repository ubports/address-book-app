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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1 as Popups
import Ubuntu.Contacts 0.1 as ContactsUI

Page {
    id: mainPage
    objectName: "ContactList"

    title: i18n.tr("Contacts")
    Component {
        id: dialog

        Popups.Dialog {
            id: dialogue

            title: i18n.tr("Error")
            text: i18n.tr("Fail to Load contacts")

            Button {
                text: "Cancel"
                gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    ContactsUI.ContactListView {
        id: contactList

        multiSelectionEnabled: true
        anchors.fill: parent
        onError: PopupUtils.open(dialog, null)
        defaultAvatarImageUrl: "artwork:/avatar-default.svg"
        swipeToDelete: true

        ActivityIndicator {
            id: activity

            anchors.centerIn: parent
            running: contactList.loading && (contactList.count === 0)
            visible: running
        }

        onContactClicked: {
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.model, contactId: contact.contactId})
        }

        onSelectionDone: {
            var ids = []
            var contacts = model.contacts
            for (var i=0; i < items.length; i++) {
                ids.push(contacts[items[i]].contactId)
            }
            contactList.model.removeContacts(ids)
        }

        onIsInSelectionModeChanged: {
            if (isInSelectionMode) {
                toolbar.opened = false
            }
        }
    }

    tools: ToolbarItems {
        id: toolbar

        locked: contactList.isInSelectionMode
        ToolbarButton {
            action: Action {
                text: i18n.tr("Add")
                iconSource: "artwork:/add.png"
                onTriggered: {
                    var newContact =  Qt.createQmlObject("import QtContacts 5.0; Contact{ }", mainPage)
                    pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   {model: contactList.model, contact: newContact})
                }

            }
        }
    }

    Connections {
        target: pageStack
        onContactRequested: {
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.model, contactId: contactId})
        }
        onCreateContactRequested: {
            var newContact =  Qt.createQmlObject("import QtContacts 5.0; Contact{ }", mainPage)
            var newDetailCode = "import QtContacts 5.0; PhoneNumber{ number: \"%1\"}".arg(phoneNumber)
            var newDetail = Qt.createQmlObject(newDetailCode, mainPage)
            newContact.addDetail(newDetail)
            pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                           {model: contactList.model, contact: newContact})
        }

    }
}
