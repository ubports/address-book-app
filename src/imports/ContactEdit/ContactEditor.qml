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

import "../Common"

Page {
    id: contactEditor
    objectName: "contactEditorPage"

    property QtObject contact: null
    property QtObject model: null
    property QtObject activeItem: null
    readonly property bool isNewContact: contact && (contact.contactId === "qtcontacts:::")
    property string initialFocusSection: ""
    property var newDetails: []

    // priv
    property bool _edgeReady: false

    function cancel() {
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
                pageStack.contactCreated(contact)
            }
        }
        pageStack.pop()
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
        contactEditor.initialFocusSection = ""
    }

    function focusToLastPhoneField()
    {
        var lastPhoneField = phonesEditor.detailDelegates[phonesEditor.detailDelegates.length - 2].item
        lastPhoneField.forceActiveFocus()
    }

    title: i18n.tr("Edit")

    Timer {
        id: focusTimer

        interval: 1000
        running: false
        repeat: false
        onTriggered: contactEditor.ready()
    }

    flickable: null
    Flickable {
        id: scrollArea
        objectName: "scrollArea"

        // this is necessary to avoid the page to appear bellow the header
        clip: true
        flickableDirection: Flickable.VerticalFlick
        anchors {
            fill: parent
            bottomMargin: keyboard.height
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
                height: Math.max(avatarEditor.height, nameEditor.height)

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

            ListItem.ThinDivider {}

            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(2)
            }

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                height: units.gu(6)
                spacing: units.gu(2)

                Button {
                    id: addNewFieldButton

                    text: i18n.tr("Add Field")
                    gradient: UbuntuColors.greyGradient
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        bottomMargin: units.gu(2)
                    }
                    width: (parent.width - units.gu(4)) / 2

                    onClicked: addFieldDialog.showOptions()
                }

                Button {
                    id: deleteButton

                    text: i18n.tr("Delete")
                    visible: !contactEditor.isNewContact
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        bottomMargin: units.gu(2)
                    }
                    width: (parent.width - units.gu(4)) / 2
                    onClicked: {
                        var dialog = PopupUtils.open(removeContactDialog, null)
                        dialog.contacts = [contactEditor.contact]
                    }
                }
            }
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

    tools: ToolbarItems {
        id: toolbar

        back: ToolbarButton {
            action: Action {
                objectName: "cancel"

                iconName: "close"
                text: i18n.tr("Cancel")
                onTriggered: {
                    contactEditor.cancel()
                    contactEditor.active = false
                }
            }
        }

        ToolbarButton {
            action: Action {
                objectName: "save"

                iconName: "save"
                text: i18n.tr("Save")
                enabled: !nameEditor.isEmpty() || !phonesEditor.isEmpty()
                onTriggered: contactEditor.save()
            }
        }
    }

    Component.onCompleted: {
        if (!enabled) {
            return
        }

        if (contactEditor.initialFocusSection != "") {
            focusTimer.restart()
        } else {
            contactEditor.ready()
        }
    }

    AddFieldDialog {
        id: addFieldDialog

        contact: contactEditor.contact
        onFieldSelected: {
            if (qmlTypeName) {
                var newDetail = Qt.createQmlObject("import QtContacts 5.0; " + qmlTypeName + "{}", addFieldDialog)
                if (newDetail) {
                    var newDetailsCopy = contactEditor.newDetails
                    newDetailsCopy.push(newDetail)
                    contactEditor.newDetails = newDetailsCopy
                    contactEditor.contact.addDetail(newDetail)
                }
            }
        }
    }

    Component {
        id: removeContactDialog

        RemoveContactsDialog {
            id: removeContactsDialogMessage

            property var popPages: false

            onCanceled: {
                PopupUtils.close(removeContactsDialogMessage)
            }

            onAccepted: {
                popPages = true
                removeContacts(contactEditor.model)
                PopupUtils.close(removeContactsDialogMessage)
            }

            // WORKAROUND: SDK element crash if pop the page where the dialog was created
            Component.onDestruction: {
                if (popPages) {
                    contactEditor.pageStack.pop() // editor page
                    contactEditor.pageStack.pop() // view page
                }
            }
        }
    }
}
