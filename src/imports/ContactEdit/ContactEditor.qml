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
import Ubuntu.Components.Popups 0.1

Page {
    id: contactEditor

    property QtObject contact: null
    property QtObject model: null

    // this is used to add a phone number to a existing contact
    property int currentFetchOperation: -1
    property string contactId: null
    property string newPhoneNumber: null

    property QtObject activeItem: null

    // we use a custom toolbar in this view
    tools: ToolbarItems {
        locked: true
        opened: false
    }

    function save() {
        var changed = false
        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.save) {
                if (field.save()) {
                    changed = true
                }
            }
        }

        // new contact and there is only two details (name, avatar)
        // name and avatar, are not removable details, because of that the contact will have at least 2 details
        if ((contact.contactId === "qtcontacts:::") &&
            (contact.contactDetails.length === 2)) {

            // if name is empty this means that the contact is empty
            var nameDetail = contact.detail(ContactDetail.Name)
            if (nameDetail &&
                (nameDetail.firstName && nameDetail.firstName != "") ||
                (nameDetail.lastName && nameDetail.lastName != "")) {
                // save contact
            } else {
                changed  = false
            }
        }

        if (changed) {
            model.saveContact(contact)
        } else {
            pageStack.pop()
        }
    }

    function makeMeVisible(item) {
        if (!item) {
            return
        }

        activeItem = item
        var position = scrollArea.contentItem.mapFromItem(item, 0, item.y);

        // check if the item is already visible
        var bottomY = scrollArea.contentY + scrollArea.height
        var itemBottom = position.y + item.height
        if (position.y >= scrollArea.contentY && itemBottom <= bottomY) {
            return;
        }

        // if it is not, try to scroll and make it visible
        var targetY = position.y + item.height - scrollArea.height
        if (targetY >= 0 && position.y) {
            scrollArea.contentY = targetY;
        } else if (position.y < scrollArea.contentY) {
            // if it is hidden at the top, also show it
            scrollArea.contentY = position.y;
        }
        scrollArea.returnToBounds()
    }

    ContactFetchError {
        id: fetchErrorDialog
    }

    Connections {
        target: model
        onContactsFetched: {
            if (requestId == currentFetchOperation) {
                currentFetchOperation = -1
                // this fetch request can only return one contact
                if(fetchedContacts.length !== 1) {
                    PopupUtils.open(fetchErrorDialog, null)
                }
                contact = fetchedContacts[0]
            }
        }
    }

    onContactIdChanged:  {
        if (contactId) {
            currentFetchOperation = model.fetchContacts(contactId)
        }
    }

    onContactChanged: {
        if (contact && (newPhoneNumber.length > 0)) {
            var detailSourceTemplate = "import QtContacts 5.0; PhoneNumber{ number: \"" + newPhoneNumber + "\" }"
            var newDetail = Qt.createQmlObject(detailSourceTemplate, contactEditor)
            if (newDetail) {
                contact.addDetail(newDetail)
                // we need to wait for the field be created
                focusTimer.restart()

            }
            newPhoneNumber = ""

        }
    }

    Timer {
        id: focusTimer

        interval: 200
        running: false
        onTriggered: {
            // get last phone field and set focus
            var lastPhoneField = phones.detailDelegates[phones.detailDelegates.length - 2].item
            lastPhoneField.forceActiveFocus()
        }
    }

    flickable: null
    Flickable {
        id: scrollArea

        flickableDirection: Flickable.VerticalFlick
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: toolbar.top
        }
        contentHeight: contents.height
        contentWidth: parent.width
        visible: !busyIndicator.visible

        // after add a new field we need to wait for the contentHeight to change to scroll to the correct position
        onContentHeightChanged: contactEditor.makeMeVisible(contactEditor.activeItem)

        Column {
            id: contents

            anchors {
                top: parent.top
                topMargin: units.gu(2)
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height

            ContactDetailNameEditor {
                id: nameEditor

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight + units.gu(3)
            }

            ContactDetailAvatarEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailPhoneNumbersEditor {
                id: phones

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailEmailsEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOnlineAccountsEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailAddressesEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOrganizationsEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }
        }
    }

    Component.onCompleted: nameEditor.forceActiveFocus()

    ActivityIndicator {
        id: busyIndicator

        running: contactSaveLock.saving
        visible: running
        anchors.centerIn: parent
    }

    Connections {
        id: contactSaveLock

        property bool saving: false

        target: contactEditor.model

        onContactsChanged: {
            if (saving) {
                pageStack.pop()
            }
        }

        onErrorChanged: {
            //TODO: show a dialog
            console.debug("Save error:" + contactEditor.model.error)
        }
    }

    EditToolbar {
        id: toolbar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: units.gu(6)
        acceptAction: Action {
            text: i18n.tr("Save")
            onTriggered: {
                // wait for contact to be saved or cause a error
                contactSaveLock.saving = true
                contactEditor.save()
            }
        }
        rejectAction: Action {
            text: i18n.tr("Cancel")
            onTriggered: pageStack.pop()
        }
    }
}
