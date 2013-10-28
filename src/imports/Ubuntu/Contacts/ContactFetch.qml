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

Item {
    id: root

    property alias model: connections.target
    property bool running: false
    property QtObject contact: null
    property bool contactIsDirty: false

    property string _pendingId: ""
    property bool _ready: false

    signal contactFetched(QtObject contact)
    signal contactRemoved()

    function fetchContact(contactId) {
        if (root._ready) {
            root._fetchContact(contactId)
        } else {
            root._pendingId = contactId
        }
    }

    function _fetchContact(contactId) {
        if (contact && !contactIsDirty && contact.contacId == contactId) {
            contactFetched(contact)
        } else {
            contact = null
            contactIsDirty = true
            running = true
            if (model.manager === "memory") {
                // memory backend emit contact fetched before return from "fetchContacts" we will use operation = "-2"
                // to say that we are wainting for a operation from memory manager
                connections.currentQueryId = -2
                model.fetchContacts([contactId])
            } else {
                connections.currentQueryId = model.fetchContacts([contactId])
                if (connections.currentQueryId === -1) {
                    running = false
                }
            }
        }
    }

    Connections {
        target: root.model

        onContactsChanged: {
            if (root.contact) {
                root.contactIsDirty = true

                for (var i=0; i < root.model.contacts.length; i++) {
                    if (root.model.contacts[i].contactId == root.contact.contactId) {
                        return
                    }
                }
                contactRemoved()
            }
        }
    }

    Connections {
        id: connections

        property int currentQueryId: -1

        onContactsFetched: {
            // currentQueryId == -2 is used during a fetch using "memory" manager
            if ((currentQueryId == -2) || (requestId == currentQueryId)) {
                root.contactIsDirty = false
                root.running = false
                currentQueryId = -1
                root.contact = fetchedContacts[0]
                root.contactFetched(fetchedContacts[0])
            }
        }
    }

    Component.onCompleted: {
        root._ready = true
        if (root._pendingId != "") {
            root._fetchContact(root._pendingId)
            root._pendingId = ""
        }
    }
}
