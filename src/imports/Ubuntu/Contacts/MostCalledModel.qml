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


import QtQuick 2.4
import QtContacts 5.0

import Ubuntu.History 0.1
import Ubuntu.Contacts 0.1 as ContactUI

VisualDataModel {
    id: root

    property var contactModel: null
    property int currentIndex: -1
    property alias callAverage: mostCalledModel.callAverage

    signal contactClicked(int index, QtObject contact)
    signal addContactClicked(string label)
    signal loaded()

    property var baseModel: HistoryEventModel {
        id: historyEventModel

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

    model: ContactUI.MostCalledContactsModel {
        id: mostCalledModel

        startInterval: new Date((new Date().getTime() - 2592000000)) // one month ago
        maxCount: 5
        onLoaded: root.loaded()
        sourceModel: historyEventModel
    }

    delegate: ContactDelegate {
        id: contactDelegate

        readonly property alias contact: contactFetch.contact
        property var contents

        defaultAvatarUrl: "image://theme/contacts"
        width: parent ? parent.width : 0
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
            if (contact) {
                root.contactClicked(index, contact)
            } else {
                root.addContactClicked(name.text)
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
