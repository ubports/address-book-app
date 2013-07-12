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

import "ContactList.js" as Sections

Page {
    id: mainPage

    title: i18n.tr("Contacts")

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
        id: contactListView

        clip: true
        snapMode: ListView.NoSnap
        section {
            property: "contact.name.firstName"
            criteria: ViewSection.FirstCharacter
            delegate: ListItem.Header {
                id: listHeader
                text: section
            }
        }

        anchors.fill: parent
        model: contactsModel
        onCountChanged: {
            dirtyTimer.restart()
        }

        function isNotEmptyString(string) {
            return (string && string.length !== 0);
        }

        function formatNameToDisplay(contact) {
            if (!contact) {
                return ""
            }

            if (contact.name) {
                var detail = contact.name
                return [detail.prefix, detail.firstName, detail.middleName, detail.lastName, detail.suffix].filter(isNotEmptyString).join(" ")
            } else if (contact.displayLabel && contact.displayLabel.label && contact.displayLabel.label !== "") {
                return contact.displayLabel.label
            } else {
                return ""
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

            onClicked: {
                pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                               {model: contactsModel, contactId: contactListView.currentItem.contactObject.contactId})
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

        running: contactListView.count == 0
        visible: running
        anchors.centerIn: contactListView
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: Action {
                text: i18n.tr("Add")
                iconSource: "artwork:/add.png"
                onTriggered: {
                    var newContact =  Qt.createQmlObject("import QtContacts 5.0; Contact{ }", mainPage)
                    pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   {model: contactsModel, contact: newContact})
                }

            }
        }
    }
}
