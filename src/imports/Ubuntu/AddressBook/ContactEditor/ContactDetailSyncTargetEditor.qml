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

import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3

import Ubuntu.Contacts 0.1
import Ubuntu.AddressBook.Base 0.1

ContactDetailBase {
    id: root

    property alias active: sourceModel.autoUpdate
    property bool isNewContact: contact && contact.contactId === "qtcontacts:::"
    property real myHeight: label.height + units.gu(6) + (sources.currentlyExpanded ? sources.containerHeight :
                                                                                      sources.itemHeight)

    signal changed()

    function save() {
        // only changes the target sync for new contacts
        if (!isNewContact) {
            return;
        }
        var activeSource = getSelectedSource()
        if (!activeSource) {
            return;
        }

        if (!root.detail) {
            root.detail = root.contact.syncTarget
        }
        root.detail.syncTarget = activeSource
    }

    function getSelectedSource() {
        if (sources.model.count <= 0)
            return -1

        var selectedSourceId = sources.model.get(sources.selectedIndex).sourceId
        if (selectedSourceId) {
            return selectedSourceId
        } else {
            return -1
        }
    }

    function contactIsReadOnly(contact) {
        var sources = sourceModel.contacts
        var contactSyncTarget = contact.syncTarget.value(SyncTarget.SyncTarget + 1)

        for (var i = 0; i < writableSources.count; i++) {
            var source = writableSources.get(i)
            if (source.sourceId === contactSyncTarget) {
                return false
            }
        }
        return true
    }

    detail: root.contact ? contact.detail(ContactDetail.SyncTarget) : null
    implicitHeight: root.isNewContact &&  sources.model && (sources.model.count > 1) ? myHeight : 0
    visible: height > 0

    ContactModel {
        id: sourceModel

        manager: (typeof(QTCONTACTS_MANAGER_OVERRIDE) !== "undefined") && (QTCONTACTS_MANAGER_OVERRIDE != "") ? QTCONTACTS_MANAGER_OVERRIDE : "org.nemomobile.contacts.sqlite"
        filter: DetailFilter {
            detail: ContactDetail.Type
            field: Type.TypeField
            value: Type.Group
            matchFlags: DetailFilter.MatchExactly
        }
        autoUpdate: false
        onContactsChanged: {
            if (contacts.length > 0) {
                writableSources.reload()
                root.changed()
            }
        }
    }

    ListModel {
        id: writableSources

        function getSourceMetaData(contact) {
            var metaData = {'read-only' : false,
                            'account-provider': '',
                            'account-id': 0,
                            'is-primary': false}

            var details = contact.details(ContactDetail.ExtendedDetail)
            for(var d in details) {
                if (details[d].name === "READ-ONLY") {
                    metaData['read-only'] = details[d].data
                } else if (details[d].name === "PROVIDER") {
                    metaData['account-provider'] = details[d].data
                } else if (details[d].name === "APPLICATION-ID") {
                    metaData['account-id'] = details[d].data
                } else if (details[d].name === "IS-PRIMARY") {
                    metaData['is-primary'] = details[d].data
                }
            }
            return metaData
        }

        function reload() {
            clear()

            // filter out read-only sources
            var contacts = sourceModel.contacts
            if (contacts.length === 0) {
                return
            }

            var data = []
            for(var i in contacts) {
                var sourceMetaData = getSourceMetaData(contacts[i])
                if (!sourceMetaData['read-only']) {
                    data.push({'sourceId': contacts[i].guid.guid,
                               'sourceName': contacts[i].displayLabel.label,
                               'accountId': sourceMetaData['account-id'],
                               'accountProvider': sourceMetaData['account-provider'],
                               'readOnly': sourceMetaData['read-only'],
                               'isPrimary': sourceMetaData['is-primary']
                                })
                }
            }

            data.sort(function(a, b) {
                var valA = a.accountId
                var valB = b.accountId
                if (a.accountId == b.accountId) {
                    valA = a.sourceName
                    valB = b.sourceName
                }

                if (valA == valB) {
                    return 0
                } else if (valA < valB) {
                    return -1
                } else {
                    return 1
                }
            })

            var primaryIndex = 0
            for (var i in data) {
                if (data[i].isPrimary) {
                    primaryIndex = i
                }
                append(data[i])
            }

            // select primary account
            sources.selectedIndex = primaryIndex
        }
    }

    Label {
        id: label

        text: i18n.dtr("address-book-app", "Addressbook")
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            margins: units.gu(2)
        }
        height: units.gu(4)
    }

    ThinDivider {
        id: divider

        anchors {
            top: label.bottom
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
   }

    OptionSelector {
        id: sources

        model: writableSources
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: divider.bottom
            topMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(2)
        }

        delegate: OptionSelectorDelegate {
            text: {
                if ((sourceId != "system-address-book") && (accountProvider == "")) {
                    return i18n.dtr("address-book-app", "Personal - %1").arg(sourceName)
                } else {
                    return sourceName
                }
            }
            height: units.gu(4)
        }

        containerHeight: sources.model && sources.model.count > 4 ? itemHeight * 4 : sources.model ? itemHeight * sources.model.count : 0
    }

    onActiveChanged: {
        if (active) {
            sourceModel.update()
        }
    }

    // In case of sources changed we need to update the model
    Connections {
        target: application
        onSourcesChanged: sourceModel.update()
    }
}

