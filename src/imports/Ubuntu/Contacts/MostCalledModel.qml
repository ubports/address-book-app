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

    property int maxCount: 10
    property var contactModel: null
    property var historyModel
    property int currentIndex: -1

    signal clicked(int index, QtObject contact)
    signal detailClicked(QtObject contact, QtObject detail, string action)
    signal infoRequested(int index, QtObject contact)
    signal addContactClicked(string label)

    function filterEntries()
    {
        var contacts = {}
        var interval = new Date()
        var secs = (interval.getTime() - 2592000000) // one month ago
        interval.setTime(secs)

        var totalCount = 0
        var i = 0;
        while(true) {
            var event = historyModel.getItem(i)
            if (!event) {
                break
            }

            if (event.timestamp < interval) {
                break
            }

            var participants = event.participants
            for (var p=0; p < participants.length; p++) {
                var phoneNumber = participants[p]
                if (phoneNumber) {
                    if (contacts[phoneNumber] === undefined) {
                        contacts[phoneNumber] = 1
                    } else {
                        var count = contacts[phoneNumber]
                        contacts[phoneNumber] = count + 1
                    }
                    totalCount += 1
                }
            }
            i++
        }

        listModel.clear()
        if (totalCount == 0) {
            return
        }

        // sort phones most called first
        var mostCalledFirst = []
        for (var key in contacts) {
            mostCalledFirst.push([key, contacts[key]]);
        }

        mostCalledFirst.sort(function(a, b) {
            a = a[1];
            b = b[1];

            return a < b ? -1 : (a > b ? 1 : 0);
        });

        contacts = {}
        for (var i = 0; i < mostCalledFirst.length; i++) {
            var key = mostCalledFirst[i][0];
            var value = mostCalledFirst[i][1];
            contacts[key] = value
        }

        // get the avarage frequency
        var average = totalCount / mostCalledFirst.length

        for (var phone in contacts) {
            if (contacts[phone] >= average) {
                listModel.insert(0, {"participant": phone})
                if (listModel.count >= root.maxCount) {
                    return;
                }
            }
        }
    }

    model: ListModel {
        id: listModel
    }

    historyModel: HistoryEventModel {

        function getItem(row) {
            while ((row >= count) && (canFetchMore())) {
                fetchMore()
            }
            return get(row)
        }

        type: HistoryThreadModel.EventTypeVoice
        sort: HistorySort {
            sortField: "timestamp"
            sortOrder: HistorySort.DescendingOrder
        }
    }


    delegate: ContactDelegate {
        id: contactDelegate

        readonly property alias contact: contactFetch.contact

        onDetailClicked: root.detailClicked(contact, detail, action)
        onInfoRequested: root.infoRequested(index, contact)
        onAddContactClicked: root.addContactClicked(label)

        defaultAvatarUrl: "image://theme/contacts"
        defaultTitle: participant
        width: parent.width
        titleDetail: ContactDetail.DisplayLabel
        titleFields: [ DisplayLabel.Label ]
        isCurrentItem: root.currentIndex === index

        // collapse the item before remove it, to avoid crash
        ListView.onRemove: SequentialAnimation {
            ScriptAction {
                script: {
                    if (contactDelegate.state !== "") {
                        historyModel.currentIndex = -1
                    }
                }
            }
        }

        onClicked: {
            if (root.currentIndex === index) {
                root.currentIndex = -1
                return
            } else if (detailToPick !== 0) {
                root.currentIndex = index
                return
            } else if (detailToPick == 0) {
                contactListView.detailClicked(contact, null, "")
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
