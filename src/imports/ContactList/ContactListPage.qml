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
    objectName: "contactListPage"

    property bool pickMode: false
    readonly property bool pickMultipleMode: pickMode && contentHub.isMultipleItems

    function createEmptyContact(phoneNumber) {
        var details = [ {detail: "PhoneNumber", field: "number", value: phoneNumber},
                        {detail: "EmailAddress", field: "emailAddress", value: ""},
                        {detail: "OnlineAccount", field: "accountUri", value: ""},
                        {detail: "Address", field: "street", value: ""},
                        {detail: "Name", field: "firstName", value: "" }
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

    function saveVCardForContact(contacts) {
        var tempFile = contentHub.createTemporaryFile()
        contactList.listModel.exportContacts(tempFile,
                                             ["Sync"],
                                             contacts)
        return tempFile
    }

    title: i18n.tr("Contacts")

    // control the pick mode single/multiple
    onPickMultipleModeChanged: {
        if (mainPage.pickMultipleMode) {
            contactList.startSelection()
        } else if (mainPage.pickMode) {
            contactList.cancelSelection()
        }
    }

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
        objectName: "contactListView"

        manager: DEFAULT_CONTACT_MANAGER
        showFavoritePhoneLabel: false
        multiSelectionEnabled: true
        acceptAction.text: pickMode ? i18n.tr("Select") : i18n.tr("Delete")

        anchors {
            // This extra margin is necessary because the toolbar area overlaps the last item in the view
            // in the selection mode we remove it to avoid visual problems due the selection bar appears
            // inside of the listview
            bottomMargin: contactList.isInSelectionMode ? 0 : units.gu(2)
            fill: parent
        }
        onError: PopupUtils.open(dialog, null)
        swipeToDelete: !pickMode

        ActivityIndicator {
            id: activity

            anchors.centerIn: parent
            running: contactList.loading && (contactList.count === 0)
            visible: running
        }

        onContactClicked: {
            if (pickMode) {
                var contacts = [contact]
                var tempFile = saveVCardForContact(contacts)
                contentHub.returnContacts(tempFile)
                pageStack.pop(contacts)
            } else {
                pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                               {model: contactList.listModel, contactId: contact.contactId})
            }
        }

        onSelectionDone: {
            if (pickMode) {
                var contacts = []
                for (var i=0; i < items.count; i++) {
                    contacts.push(items.get(i).model.contact)
                }
                var tempFile = saveVCardForContact(contacts)
                contentHub.returnContacts(tempFile)
                pageStack.pop()
            } else {
                var ids = []
                for (var i=0; i < items.count; i++) {
                    ids.push(items.get(i).model.contact.contactId)
                }
                contactList.listModel.removeContacts(ids)
            }
        }
        onSelectionCanceled: {
            if (pickMode) {
                contentHub.cancelTransfer()
                pageStack.pop()
            }
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
            objectName: "Add"
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
        onEditContatRequested: {
            pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                           {model: contactList.listModel, contactId: contactId, newPhoneNumber: phoneNumber })
        }
        onContactCreated: {
            contactList.positionViewAtContact(contact)
        }
    }

    Component.onCompleted: {
        if (pickMultipleMode) {
            contactList.startSelection()
        }
    }
}
