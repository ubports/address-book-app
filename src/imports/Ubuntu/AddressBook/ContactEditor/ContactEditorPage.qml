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

import QtQuick 2.2
import QtContacts 5.0

import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3

import Ubuntu.AddressBook.Base 0.1

Page {
    id: contactEditor

    property QtObject contact: null
    property QtObject model: null
    property QtObject activeItem: null


    property string initialFocusSection: ""
    property var newDetails: []

    readonly property bool isNewContact: contact && (contact.contactId === "qtcontacts:::")
    readonly property bool isContactValid: !avatarEditor.busy && (!nameEditor.isEmpty() || !phonesEditor.isEmpty())

    signal contactSaved(var contact);
    signal cancelled();

    // priv
    property bool _edgeReady: false

    function cancel(cancelledCallback, cancelledCallbackParameters) {
        PopupUtils.open(cancelEditDialogComponent, null,
                        {"cancelledCallback": cancelledCallback,
                         "cancelledCallbackParameters": cancelledCallbackParameters});
    }

    function doCancel() {
        for (var i = 0; i < contactEditor.newDetails.length; ++i) {
            contactEditor.contact.removeDetail(contactEditor.newDetails[i])
        }
        contactEditor.newDetails = []

        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.cancel) {
                field.cancel()
            }
        }
        contactEditor.cancelled()
        pageStack.removePages(contactEditor)
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
        if (isNewContact &&
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
                contactEditor.contactSaved(contact)
            }
        }
        pageStack.removePages(contactEditor)
    }

    function makeMeVisible(item) {
        if (!_edgeReady || !item) {
            return
        }

        activeItem = item
        var position = scrollArea.contentItem.mapFromItem(item, 0, activeItem.y);

        // check if the item is already visible
        var bottomY = scrollArea.contentY + scrollArea.height
        var itemBottom = position.y + (item.height * 3) // extra margin
        if (position.y >= scrollArea.contentY && itemBottom <= bottomY) {
            return;
        }

        // if it is not, try to scroll and make it visible
        var targetY = itemBottom - scrollArea.height
        if (targetY >= 0 && position.y) {
            scrollArea.contentY = targetY;
        } else if (position.y < scrollArea.contentY) {
            // if it is hidden at the top, also show it
            scrollArea.contentY = position.y;
        }
        scrollArea.returnToBounds()
    }

    function ready()
    {
        console.debug("READYYYYY: " + contactEditor.initialFocusSection)
        enabled = true
        _edgeReady = true

        switch (contactEditor.initialFocusSection)
        {
        case "phones":
            contactEditor.focusToLastPhoneField()
            break;
        case "name":
            nameEditor.fieldDelegates[0].forceActiveFocus()
            break;
        }
    }

    function focusToLastPhoneField()
    {
        var lastPhoneField = phonesEditor.detailDelegates[phonesEditor.detailDelegates.length - 2].item
        console.debug("Focus last phone field:" + lastPhoneField)
        console.debug("PHONES SIZE>" + phonesEditor.detailDelegates.length)
        lastPhoneField.forceActiveFocus()
    }

    title: isNewContact ? i18n.dtr("address-book-app", "New contact") : i18n.dtr("address-book-app", "Edit")

    Timer {
        id: focusTimer

        interval: 1000
        running: false
        repeat: false
        onTriggered: contactEditor.ready()
    }


    Component {
        id: cancelEditDialogComponent

        CancelEditDialog {
            id: cancelEditDialog

            onDiscardClicked: {
                cancelConfirmed = true;
                PopupUtils.close(cancelEditDialog);
            }

            onKeepEditingClicked: {
                PopupUtils.close(cancelEditDialog);
            }

            property var cancelledCallback
            property var cancelledCallbackParameters
            property bool cancelConfirmed: false
            Component.onDestruction: if (cancelConfirmed) {
                                         contactEditor.doCancel();
                                         if (cancelledCallback) {
                                            cancelledCallback(cancelledCallbackParameters);
                                         }
                                     }
        }
    }

    flickable: null
    Flickable {
        id: scrollArea
        objectName: "scrollArea"

        // this is necessary to avoid the page to appear bellow the header
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors{
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: keyboardRectangle.top
        }
        contentHeight: contents.height + units.gu(2)
        contentWidth: parent.width

        //after add a new field we need to wait for the contentHeight to change to scroll to the correct position
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

            Row {
                function save()
                {
                    var avatarSave = avatarEditor.save()
                    var nameSave = nameEditor.save();

                    return (nameSave || avatarSave);
                }

                function isEmpty()
                {
                    return (avatarEditor.isEmpty() && nameEditor.isEmpty())
                }

                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    right: parent.right
                }
                height: Math.max(avatarEditor.height, nameEditor.height) - units.gu(4)

                ContactDetailAvatarEditor {
                    id: avatarEditor

                    contact: contactEditor.contact
                    height: implicitHeight
                    width: implicitWidth
                }

                ContactDetailNameEditor {
                    id: nameEditor

                    width: parent.width - avatarEditor.width
                    height: nameEditor.implicitHeight + units.gu(3)
                    contact: contactEditor.contact
                }
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
            }

            ContactDetailAddressesEditor {
                id: addressesEditor
                objectName: "addresses"

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOrganizationsEditor {
                id: organizationsEditor
                objectName: "professionalDetails"

                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailSyncTargetEditor {
                id: syncTargetEditor

                active: contactEditor.active
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ThinDivider {}

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(2)
            }

            ComboButtonAddField {
                id: addNewFieldButton
                objectName: "addNewFieldButton"

                contact: contactEditor.contact
                text: i18n.dtr("address-book-app", "Add Field")
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                height: implicitHeight
                onHeightChanged: {
                    if (expanded && (height === expandedHeight) && !scrollArea.atYEnd) {
                        moveToBottom.start()
                    }
                }

                UbuntuNumberAnimation {
                    id: moveToBottom

                    target: scrollArea
                    property: "contentY"
                    from: scrollArea.contentY
                    to: Math.min(scrollArea.contentHeight - scrollArea.height,
                                 scrollArea.contentY + (addNewFieldButton.height - addNewFieldButton.collapsedHeight - units.gu(3)))
                }

                onFieldSelected: {
                    if (qmlTypeName) {
                        var newDetail = Qt.createQmlObject("import QtContacts 5.0; " + qmlTypeName + "{}", contactEditor)
                        if (newDetail) {
                            var newDetailsCopy = contactEditor.newDetails
                            newDetailsCopy.push(newDetail)
                            contactEditor.newDetails = newDetailsCopy
                            contactEditor.contact.addDetail(newDetail)
                        }
                    }
                }
            }


            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(2)
            }

            Button {
                id: deleteButton

                text: i18n.dtr("address-book-app", "Delete")
                visible: !contactEditor.isNewContact
                color: UbuntuColors.red
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                onClicked: {
                    var dialog = PopupUtils.open(removeContactDialog, null)
                    dialog.contacts = [contactEditor.contact]
                }
            }


            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(2)
            }
        }
    }

    KeyboardRectangle {
        id: keyboardRectangle

        onHeightChanged: {
            if (activeItem) {
                makeMeVisible(activeItem)
            }
        }
    }

    Component.onCompleted: {
        console.debug("Editor completed: " + enabled)
        if (!enabled) {
            return
        }

        console.debug("initialFocusSection: " + contactEditor.initialFocusSection)
        if (contactEditor.initialFocusSection != "") {
            focusTimer.restart()
        } else {
            contactEditor.ready()
        }
    }

    Component {
        id: removeContactDialog

        RemoveContactsDialog {
            id: removeContactsDialogMessage

            property bool popPages: false

            onCanceled: {
                PopupUtils.close(removeContactsDialogMessage)
            }

            onAccepted: {
                popPages = true
                removeContacts(contactEditor.model)
                PopupUtils.close(removeContactsDialogMessage)
            }

            // hide virtual keyboard if necessary
            Component.onCompleted: Qt.inputMethod.hide()

            // WORKAROUND: SDK element crash if pop the page where the dialog was created
            Component.onDestruction: {
                if (popPages) {
                    contactEditor.pageStack.removePages(contactEditor)
                }
            }
        }
    }
}
