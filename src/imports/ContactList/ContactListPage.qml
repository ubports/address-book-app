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

    function createEmptyContact(phoneNumber) {
        var details = [ {detail: "PhoneNumber", field: "number", value: phoneNumber},
                        {detail: "EmailAddress", field: "emailAddress", value: ""},
                        {detail: "OnlineAccount", field: "accountUri", value: ""},
                        {detail: "Address", field: "street", value: ""}
                      ]

        var newContact =  Qt.createQmlObject("import QtContacts 5.0; Contact{ }", mainPage)
        var detailSourceTemplate = "import QtContacts 5.0; %1{ %2: \"%3\" }"
        for (var i=0; i < details.length; i++) {
            var detailMetaData = details[i]
            var newDetail = Qt.createQmlObject(detailSourceTemplate.arg(detailMetaData.detail)
                                            .arg(detailMetaData.field)
                                            .arg(detailMetaData.value), mainPage)
            newContact.addDetail(newDetail)
        }
        return newContact
    }

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
                           {model: contactList.listModel, contactId: contact.contactId})
        }

        onSelectionDone: {
            var ids = []
            for (var i=0; i < items.count; i++) {
                ids.push(items.get(i).model.contact.contactId)
            }
            contactList.listModel.removeContacts(ids)
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
                objectName: "selectButton"
                text: i18n.tr("Select")
                iconSource: "artwork:/select.png"
                onTriggered: contactList.startSelection()
            }
        }
        ToolbarButton {
            action: Action {
                text: i18n.tr("Add")
                iconSource: "artwork:/add.png"
                onTriggered: {
                    var newContact = mainPage.createEmptyContact("")
                    pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   {model: contactList.listModel, contact: newContact})
                }
            }
        }
    }

    Connections {
        target: pageStack
        onContactRequested: {
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.listModel, contactId: contactId})
        }
        onCreateContactRequested: {
            var newContact = mainPage.createEmptyContact(phoneNumber)
            pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                           {model: contactList.listModel, contact: newContact})
        }
    }
}
