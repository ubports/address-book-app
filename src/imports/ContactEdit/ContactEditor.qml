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
import Ubuntu.Contacts 0.1 as ContactsUI

Page {
    id: contactEditor
    objectName: "contactEditorPage"

    property QtObject contact: null
    property alias model: contactFetch.model

    // this is used to add a phone number to a existing contact
    property string contactId: ""
    property string newPhoneNumber: ""

    property QtObject activeItem: null

    // we use a custom toolbar in this view
    tools: ToolbarItems {
        locked: true
        opened: false
    }

    function cancel() {
        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.cancel) {
                field.cancel()
            }
        }
        pageStack.pop()
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
            // backend error will be handled by the root page (contact list)
            var newContact = (contact.model == null)
            contactEditor.model.saveContact(contact)
            if (newContact) {
                pageStack.contactCreated(contact)
            }
        }
        pageStack.pop()
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

    ContactsUI.ContactFetch {
        id: contactFetch

        onContactNotFound: PopupUtils.open(fetchErrorDialog, null)
        onContactFetched: {
            if (contactEditor.contact == null) {
                contactEditor.contact = contact
            }
        }
    }

    Timer {
        id: focusTimer

        interval: 200
        running: false
        onTriggered: {
            // get last phone field and set focus
            var lastPhoneField = phonesEditor.detailDelegates[phonesEditor.detailDelegates.length - 2].item
            lastPhoneField.forceActiveFocus()
        }
    }

    flickable: null
    Flickable {
        id: scrollArea
        objectName: "scrollArea"

        flickableDirection: Flickable.VerticalFlick
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: toolbar.top
            bottomMargin: units.gu(2)
        }
        contentHeight: contents.height
        contentWidth: parent.width

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
                KeyNavigation.tab: phonesEditor
                KeyNavigation.backtab : syncTargetEditor
            }

            ContactDetailAvatarEditor {
                id: avatarEditor

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : nameEditor
                KeyNavigation.tab: phonesEditor
            }

            ContactDetailPhoneNumbersEditor {
                id: phonesEditor
                objectName: "phones"

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : avatarEditor
                KeyNavigation.tab: emailsEditor
            }

            ContactDetailEmailsEditor {
                id: emailsEditor
                objectName: "emails"

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : phonesEditor
                KeyNavigation.tab: accountsEditor
            }

            ContactDetailOnlineAccountsEditor {
                id: accountsEditor
                objectName: "ims"

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : emailsEditor
                KeyNavigation.tab: addressesEditor
            }

            ContactDetailAddressesEditor {
                id: addressesEditor

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : accountsEditor
                KeyNavigation.tab: organizationsEditor
            }

            ContactDetailOrganizationsEditor {
                id: organizationsEditor

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : addressesEditor
                KeyNavigation.tab: syncTargetEditor
            }

            ContactDetailSyncTargetEditor {
                id: syncTargetEditor

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                KeyNavigation.backtab : organizationsEditor
                KeyNavigation.tab: nameEditor
            }
        }
    }

    EditToolbar {
        id: toolbar
        anchors {
            left: parent.left
            right: parent.right
            bottom: keyboard.top
        }
        height: units.gu(6)
        acceptAction: Action {
            text: i18n.tr("Save")
            enabled: !nameEditor.isEmpty
            onTriggered: contactEditor.save()
        }
        rejectAction: Action {
            text: i18n.tr("Cancel")
            onTriggered: contactEditor.cancel()
        }
    }

    KeyboardRectangle {
        id: keyboard

        onHeightChanged: {
            if (activeItem) {
                makeMeVisible(activeItem)
            }
        }
    }

    // This will load the contact information and add the new phone number
    // when the app was launched with the URI: addressbook:///addphone?id=<contact-id>&phone=<phone-number>
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

    Component.onCompleted: {
        if (contactId !== "") {
            contactFetch.fetchContact(contactId)
        }
        nameEditor.forceActiveFocus()
    }
}
