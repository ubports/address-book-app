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

Item {
    id: root

    readonly property alias contact: connections.contact
    readonly property alias contactId: connections.contactId
    property alias model: connections.target

    property bool running: false
    property bool contactIsDirty: false

    property string _pendingId: ""
    property bool _withConstituents: false
    property bool _ready: false

    signal contactFetched(QtObject contact, var constituents,
                          QtObject mainConstituent)
    signal contactRemoved()
    signal contactNotFound()

    function fetchContact(contactId) {
        root._withConstituents = false
        if (root._ready) {
            root._fetchContact(contactId)
        } else {
            root._pendingId = contactId
        }
    }

    function fetchContactFull(contactId) {
        root._withConstituents = true
        if (root._ready) {
            root._fetchContact(contactId)
        } else {
            root._pendingId = contactId
        }
    }

    function _fetchContact(contactId) {
        if (running) {
            console.warn("Fetch already running!")
            return
        }

        if (contact && !contactIsDirty && contact.contacId == contactId) {
            if (root._withConstituents) {
                root._fetchConstituents(contact)
            } else {
                running = false
                contactFetched(contact, [], null)
            }
        } else if (model) {
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

    function _fetchConstituents(contact) {
        model.enumerateConstituents(contact, function(contacts) {
            var mainConstituent = null
            for (var i = 0; i < contacts.length; i++) {
                /* TODO: add support for the case when there are multiple
                 * constituents */
                mainConstituent = contacts[i]
            }
            running = false
            root.contactFetched(root.contact, contacts, mainConstituent)
        })
    }

    onContactChanged: {
        if (contact == null) {
            contactRemoved()
        }
    }

    Connections {
        id: connections

        property int currentQueryId: -1
        property QtObject contact: null
        property string contactId: contact ? contact.contactId : ""

        ignoreUnknownSignals: true
        onContactsFetched: {
            // currentQueryId == -2 is used during a fetch using "memory" manager
            if ((currentQueryId == -2) || (requestId == currentQueryId)) {
                root.contactIsDirty = false
                root.running = false
                currentQueryId = -1
                if (fetchedContacts.length > 0) {
                    contact = fetchedContacts[0]
                    if (root._withConstituents) {
                        root._fetchConstituents(contact)
                    } else {
                        root.contactFetched(fetchedContacts[0], [], null)
                    }
                } else {
                    contactNotFound()
                }
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
