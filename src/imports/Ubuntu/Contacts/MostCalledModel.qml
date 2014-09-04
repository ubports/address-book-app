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
import Ubuntu.Contacts 0.1

VisualDataModel {
    id: root

    property var contactModel: null
    property int currentIndex: -1
    property alias callAverage: mostCalledModel.callAverage

    signal clicked(int index, QtObject contact)
    signal detailClicked(QtObject contact, QtObject detail, string action)
    signal addDetailClicked(QtObject object, int detailType)
    signal infoRequested(int index, QtObject contact)
    signal addContactClicked(string label)
    signal loaded()

    HistoryEventModel {
        id: eventModel

        type: HistoryThreadModel.EventTypeVoice
        sort: HistorySort {
            sortField: "timestamp"
            sortOrder: HistorySort.DescendingOrder
        }
        filter: HistoryFilter {
            filterProperty: "senderId"
            filterValue: "self"
            matchFlags: HistoryFilter.MatchCaseSensitive
        }
        onCanFetchMoreChanged: {
            if (count === 0) {
                mostCalledModel.update()
            }
        }
    }

    model: MostCalledContactsModel {
        id: mostCalledModel

        startInterval: new Date((new Date().getTime() - 2592000000)) // one month ago
        onLoaded: root.loaded()
        sourceModel: eventModel
    }

    delegate: ContactDelegate {
        id: contactDelegate

        readonly property alias contact: contactFetch.contact
        property var contents

        onDetailClicked: root.detailClicked(contact, detail, action)
        onAddDetailClicked: root.addDetailClicked(contact, detailType)
        onInfoRequested: root.infoRequested(index, contact)
        onAddContactClicked: root.addContactClicked(label)

        defaultAvatarUrl: "image://theme/contacts"
        width: parent ? parent.width : 0
        titleDetail: ContactDetail.DisplayLabel
        titleFields: [ DisplayLabel.Label ]
        isCurrentItem: root.currentIndex === index
        locked: true

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
            } else if (detailToPick !== -1) {
                root.currentIndex = index
            } else if (detailToPick === -1) {
                detailClicked(contact, null, "")
            }
        }

        // delegate does not support more than one child
        contents: ContactFetch {
                id: contactFetch
                model: contactsModel
        }

        Component.onCompleted: contactFetch.fetchContact(contactId)
    }
}
