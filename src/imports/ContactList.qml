/*
 * Copyright 2012-2013 Canonical Ltd.
 *
 * This file is part of address-book-app.
 *
 * phone-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * phone-app is distributed in the hope that it will be useful,
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

import "ContactList.js" as Sections

Page {
    id: mainPage

    property var startTime

    Component.onCompleted: mainPage.startTime = new Date()

    ContactModel {
        id: contactsModel

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
            bottom: status.top
        }
        model: contactsModel
        onCountChanged: {
            dirtyTimer.restart()
            if (mainPage.startTime) {
                var currentTime = new Date();
                var elapsed = currentTime.getTime() - mainPage.startTime.getTime()
                status.text = "Elapsed time to load " + count + " contacts: " + (elapsed/1000) + " secs"
            }
        }

        function isNotEmptyString(value) {
            return (value && value.length !== 0);
        }

        function formatNameToDisplay(contact) {
            if (!contact) {
                console.debug("No contact")
                return ""
            }

            if (contact.displayLabel && contact.displayLabel.label && contact.displayLabel.label !== "") {
                console.debug("display:" + contact.displayLabel.label)
                return contact.displayLabel.label
            } else if (contact.name) {
               return [contact.name.prefix, contact.name.firstName, contact.name.middleName, contact.name.lastName, contact.name.suffix].filter(isNotEmptyString).join(" ")
            } else {
                return "XXX"
            }
        }

        delegate: ListItem.Subtitled {
            property variant contactObject: contact
            property string contactId: contact.contactId
            property string sectionName: ListView.section

            icon: contact && contact.avatar && (contact.avatar.imageUrl != "") ?  Qt.resolvedUrl(contact.avatar.imageUrl) : "artwork:/avatar-default.png"
            text: contactListView.formatNameToDisplay(contactObject)
            subText: contact && contact.phoneNumber ? contact.phoneNumber.number : ""
            selected: contactListView.currentIndex === index

            MouseArea {
                anchors.fill:  parent
                onClicked: {
                    contactListView.currentIndex = index
                }
                onDoubleClicked: {
                    editContactPriv.edit(contactListView.currentItem.contactObject.contactId)
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

    Label {
        id: status
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: units.gu(1)
        }
        height: units.gu(3)
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
            text: i18n.tr("Details")
            iconSource: "artwork:/edit.png"
            onTriggered: editContactPriv.edit(contactListView.currentItem.contactObject.contactId)
        }
        Action {
            text: i18n.tr("New")
            iconSource: "artwork:/add.png"
            onTriggered: console.debug("Not implemented")
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

        property int currentQueryId: -1

        visible: false
        Connections {
            target: contactsModel
            onContactsFetched: {
                if (requestId == editContactPriv.currentQueryId) {
                    busyIndicator.pageIsBusy = false
                    editContactPriv.currentQueryId = -1
                    pageStack.push(Qt.resolvedUrl("ContactView/ContactEditor.qml"),
                                   {model: contactsModel, contact: fetchedContacts[0]})
                }
            }
        }

        function edit(contactId) {
            if (!contactId || (currentQueryId != -1)) {
                console.debug("in progress...")
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
