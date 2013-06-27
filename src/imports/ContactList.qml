  /****************************************************************************
  **
  ** Copyright (C) 2013 Canonical Ltd
  **
  ****************************************************************************/
import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "ContactList.js" as Sections

Page {
    id: mainPage

    property var startTime

    Component.onCompleted: mainPage.startTime = new Date()

    ContactModel {
        id: contactsModel

        property string titleField : "First name"
        property string subTitleField: "Phone"
        property alias sortOrderField: sortOrder.field

        manager: "galera"
        sortOrders: [
            SortOrder {
                id: sortOrder

                detail: ContactDetail.Name
                field: Name.FirstName
                direction: Qt.AscendingOrder
            }
        ]

        fetchHint: FetchHint {
            detailTypesHint: [ContactDetail.Avatar,
                              ContactDetail.Name,
                              ContactDetail.PhoneNumber]
        }

        Component.onCompleted: {
            if (manager == "memory")
                contactsModel.importContacts(Qt.resolvedUrl("example.vcf"))
        }

        function getContactDetails(contact, fieldNames) {
            var fullValue = ""

            if (contact) {
                var fieldNameList = fieldNames.split(",")
                for (var fieldNameIndex in fieldNameList) {
                    var fieldName = fieldNameList[fieldNameIndex]
                    var value = "";
                    if (fieldName === "First name") {
                        value = contact.name.firstName
                    } else if (fieldName === "Middle name") {
                        value = contact.name.middleName
                    } else if (fieldName === "Last name") {
                        value = contact.name.lastName
                    } else if (fieldName === "Full name") {
                        value = contact.displayLabel.label
                    } else if (fieldName === "Nickname") {
                        value = contact.nickname.nickname
                    } else if (fieldName === "Phone") {
                        value = contact.phoneNumber.number
                    } else if (fieldName === "e-mail") {
                        value = contact.email.emailAddress
                    } else {
                        value = "null"
                    }
                    if (fullValue.length != 0)
                        fullValue += ", "
                    fullValue += value
                }
            }
            return fullValue
        }
    }

    ListView {
        id: alphabetView

        property string selectedLetter: contactListView.contentY > 0  ? contactListView.itemAt(0, contactListView.contentY).sectionName : "A"

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        focus: true
        height: units.gu(4)
        orientation: ListView.Horizontal

        model: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" ]
        delegate: Label {
            text: modelData
            font.bold: alphabetView.selectedLetter == text
            horizontalAlignment: Text.AlignHCenter
            fontSize: "large"
            width: units.gu(3)

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    contactListView.scroolToSection(modelData)
                }
            }

        }
    }

    ListView {
        id: contactListView

        property string title

        clip: true
        snapMode: ListView.NoSnap
        section {
            property: "contact.name.firstName"
            criteria: ViewSection.FirstCharacter
            delegate: ListItem.Header {
                id: listHeader
                //text: section
                visible: false
                height: 0
            }
        }

        anchors {
            top: alphabetView.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        model: contactsModel
        header: ListItem.Header {
            text: contactListView.title
        }

        onCountChanged: {
            dirtyTimer.restart()
            if (mainPage.startTime) {
                var currentTime = new Date();
                var elapsed = currentTime.getTime() - mainPage.startTime.getTime()
                contactListView.title = "Elapsed time to load " + count + " contacts: " + (elapsed/1000) + " secs"
            }
        }

        delegate: ListItem.Subtitled {
            property variant contactObject: contact
            property string contactId: contact.contactId
            property string sectionName: ListView.section

            icon: contact && contact.avatar && (contact.avatar.imageUrl != "") ?  Qt.resolvedUrl(contact.avatar.imageUrl) : "artwork:/avatar.png"
            text: contactsModel.titleField ? contactsModel.getContactDetails(contact, contactsModel.titleField) : ""
            subText: contactsModel.subTitleField ? contactsModel.getContactDetails(contact, contactsModel.subTitleField) : ""
            selected: contactListView.currentIndex === index

            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    contactListView.currentIndex = index
                }
                onDoubleClicked: {
                    editContactPriv.contactId = contactListView.currentItem.contactObject.contactId
                }
            }
        }

        UbuntuNumberAnimation { id: scroolToSectionAnimation; target: contactListView; property: "contentY"; }
        function scroolToSection(targetSection) {
            scroolToSectionAnimation.from = contactListView.contentY
            contactListView.positionViewAtIndex(Sections.getIndexFor(targetSection), ListView.Beginning)
            scroolToSectionAnimation.to = contactListView.contentY
            scroolToSectionAnimation.running = true
        }

        // function used to build the section cache by "ContactList.js"
        function sectionValueForContact(contact) {
            if (contact) {
                return contact.name && contact.name.firstName ? contact.name.firstName[0] : ""
            } else {
                return null
            }
        }
    }

    Timer {
        id: dirtyTimer

        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            Sections.initSectionData(contactListView)
        }
    }

    ActivityIndicator {
        id: busyIndicator

        property bool pageIsBusy: false

        running: contactListView.count == 0 || pageIsBusy
        visible: running
        anchors.centerIn: contactListView
    }

    tools: ToolbarActions {
        Action {
            text: i18n.tr("Settings")
            iconSource: "artwork:/settings.png"
            onTriggered: pageStack.push(Qt.resolvedUrl("ContactSettings.qml"), {model: contactsModel})
        }

        Action {
            text: i18n.tr("Edit")
            iconSource: "artwork:/edit.png"
            onTriggered: {
                editContactPriv.contactId = contactListView.currentItem.contactObject.contactId
            }
        }
        Action {
            text: i18n.tr("New")
            iconSource: "artwork:/add.png"
            onTriggered: pageStack.push(Qt.resolvedUrl("ContactEditor.qml"), {model: contactsModel})
        }
        Action {
            text: i18n.tr("Delete")
            iconSource: "artwork:/delete.png"
            onTriggered: {
                contactsModel.removeContact(contactListView.currentItem.contactId);
            }
        }
    }

    Item {
        id: editContactPriv

        property string contactId
        property int currentQueryId: -1

        visible: false
        Connections {
            target: contactsModel
            onContactsFetched: {
                if (requestId == editContactPriv.currentQueryId) {
                    busyIndicator.pageIsBusy = false
                    pageStack.push(Qt.resolvedUrl("ContactEditor.qml"),
                                   {model: contactsModel, contact: fetchedContacts[0]})
                }
            }
        }

        onContactIdChanged: {
            if (!contactId || (currentQueryId != -1)) {
                return
            }

            busyIndicator.pageIsBusy = true

            currentQueryId = contactsModel.fetchContacts([contactId])
            if (currentQueryId == -1) {
                busyIndicator.pageIsBusy = false
            }
        }


    }


}
