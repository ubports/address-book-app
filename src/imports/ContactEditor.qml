/****************************************************************************
**
** Copyright (C) 2013 Canonical Ltd
**
****************************************************************************/

import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: contactEditor

    property variant contact: null
    property variant model: null

    Column {
        anchors.fill: parent

        TextArea {
            id: contactFirstName

            width: parent.width
            height: units.gu(4)
            maximumLineCount: 0
            placeholderText: "First Name"
            Component.onCompleted: text = contact ? contact.name.firstName : ""
        }
        ListItem.ThinDivider {}

       TextArea {
            id: contactMiddleName

            width: parent.width
            height: units.gu(4)
            maximumLineCount: 0
            placeholderText: "Middle Name"
            Component.onCompleted: text = contact ? contact.name.middleName : ""
        }
        ListItem.ThinDivider {}

        TextArea {
            id: contactLastName

            width: parent.width
            height: units.gu(4)
            maximumLineCount: 0
            placeholderText: "Last Name"
            Component.onCompleted: text = contact ? contact.name.lastName : ""
        }
        ListItem.ThinDivider {}

        TextArea {
            id: contactPhone

            width: parent.width
            height: units.gu(4)
            maximumLineCount: 0
            placeholderText: "Phone Number"
            Component.onCompleted: text = contact ? contact.phoneNumber.number : ""
        }
        ListItem.ThinDivider {}

        TextArea {
            id: contactEmail

            width: parent.width
            height: units.gu(4)
            maximumLineCount: 0
            placeholderText: "e-mail"
            Component.onCompleted: text = contact ? contact.email.emailAddress : ""
        }
        ListItem.ThinDivider {}
    }

    function setContactDetails(contact) {
        contact.name.firstName = contactFirstName.text
        contact.name.middleName = contactMiddleName.text
        contact.name.lastName = contactLastName.text
        contact.email.emailAddress = contactEmail.text
        contact.phoneNumber.number = contactPhone.text
    }

    function updateContact() {
        if (!contact) { // create new contact
            var newContact = Qt.createQmlObject("import QtContacts 5.0; Contact{ }", contactEditor)
            setContactDetails(newContact)
            newContact.save()
            contactEditor.model.saveContact(newContact)

        } else if ((contactFirstName.text !== contactEditor.contact.name.firstName) ||
                   (contactMiddleName.text !== contactEditor.contact.name.middleName) ||
                   (contactLastName.text !== contactEditor.contact.name.lastName) ||
                   (contactEmail.text !== contactEditor.contact.email.emailAddress) ||
                   (contactPhone.text !== contactEditor.contact.phoneNumber.number)) {
            // update existing contact
            setContactDetails(contactEditor.contact)
            contact.save()
        }
    }

    tools: ToolbarActions {
        Action {
            text: i18n.tr("Save")
            iconSource: "artwork:/edit.png"
            onTriggered: {
                updateContact()
                pageStack.pop()
            }
        }
    }
}
