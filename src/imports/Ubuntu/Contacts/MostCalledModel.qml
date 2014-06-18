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
import Ubuntu.History 0.1
import Ubuntu.Telephony 0.1

VisualDataModel {
    id: root

    property int minCalls: 1
    property int maxCount: 20
    property var contactModel: null
    property var threadModel

    signal clicked(int index, QtObject contact)
    signal detailClicked(QtObject contact, QtObject detail, string action)
    signal infoRequested(int index, QtObject contact)


    function filterEntries()
    {
        var contacts = {}

        for(var i=0; i < threadModel.count; i++) {
            var participants = threadModel.get(i, "participants")
            var phoneNumber = null
            if (participants && (participants.length > 0)) {
                phoneNumber = participants[0];
            }

            if (phoneNumber) {
                if (contacts[phoneNumber] === undefined) {
                    contacts[phoneNumber] = 1
                } else {
                    var count = contacts[phoneNumber]
                    contacts[phoneNumber] = count + 1
                }
            }
        }

        listModel.clear()
        for (var phone in contacts) {
            if (contacts[phone] >= minCalls) {
                listModel.append({"participant": phone})
            }
        }
    }

    model: ListModel {
        id: listModel
    }

    threadModel: HistoryThreadModel {
        type: HistoryThreadModel.EventTypeVoice
        sort: HistorySort {
            sortField: "count"
            sortOrder: HistorySort.DescendingOrder
        }
        onCountChanged: root.filterEntries()
        Component.onCompleted: root.filterEntries()
    }


    delegate: ContactDelegate {
        id: contactDelegate

        readonly property alias contact: contactFetch.contact

        onDetailClicked: root.detailClicked(contact, detail, action)
        onInfoRequested: root.infoRequested(index, contact)

        defaultAvatarUrl: "image://theme/contacts"
        defaultTitle: participant
        width: parent.width
        titleDetail: ContactDetail.DisplayLabel
        titleFields: [ DisplayLabel.Label ]

        // collapse the item before remove it, to avoid crash
        ListView.onRemove: SequentialAnimation {
            ScriptAction {
                script: {
                    if (contactDelegate.state !== "") {
                        //contactListView.currentIndex = -1
                    }
                }
            }
        }

        onClicked: {
            if (ListView.isCurrentItem) {
                //contactListView.currentIndex = -1
                return
            // check if we should expand and display the details picker
            } else if (detailToPick !== 0) {
                //contactListView.currentIndex = indexWatcher
                return
            } else if (detailToPick == 0) {
                //contactListView.detailClicked(contact, null, "")
            }
        }

        ContactWatcher {
            id: contactWatcher

            phoneNumber: participant
            onContactIdChanged: contactFetch.fetchContact(contactId)
        }

        ContactFetch {
            id: contactFetch

            model: contactsModel
        }
    }
}
