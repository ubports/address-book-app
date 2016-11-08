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
import Ubuntu.Content 1.3
import Ubuntu.Components.Popups 1.3

Item {
    id: root

    property var contactModel
    property bool exportToDisk: true
    property var activeTransfer: null

    signal contactsFetched(var contacts)
    signal done(string outputFile)

    function start(contacts) {
        if (!contactModel) {
            console.error("No contact model defined")
            return
        }

        // skip if a query is running
        if (priv.currentQueryId != -1) {
            console.error("Export already running")
            return
        }

        if (!priv.busyDialog) {
            priv.busyDialog = PopupUtils.open(Qt.resolvedUrl("BusyExportingDialog.qml"), root)
        }

        var ids = []
        for (var i=0; i < contacts.length; i++) {
            ids.push(contacts[i].contactId)
        }
        if (ids.length == 0) {
            console.debug("The contact list is empty")
            done("")
        } else {
            if (root.contactModel.manager === "memory") {
                // memory backend emit contact fetched before return from "fetchContacts" we will use operation = "-2"
                // to say that we are wainting for a operation from memory manager
                priv.currentQueryId = -2
                contactModel.fetchContacts(ids)
            } else {
                priv.currentQueryId = contactModel.fetchContacts(ids)
            }
        }
    }

    function dismissBusyDialog()
    {
        if (priv.busyDialog) {
            PopupUtils.close(priv.busyDialog)
            priv.busyDialog = null
        }
    }

    Item {
        id: priv

        property var busyDialog: null
        property int currentQueryId: -1
        readonly property var detailsBlackList: [ ContactDetail.Favorite,
                                                  ContactDetail.Tag,
                                                  ContactDetail.ExtendedDetail,
                                                  ContactDetail.Guid ]

        function filterContactDetails(contact)
        {
            var newContact = Qt.createQmlObject("import QtContacts 5.0;  Contact { }", root)
            var allDetails = contact.contactDetails
            for(var i=0; i < allDetails.length; i++) {
                var det = allDetails[i]
                if (detailsBlackList.indexOf(det.type) == -1) {
                    newContact.addDetail(det)
                }
            }
            return newContact
        }

        function generateOutputFileName(contacts)
        {
            if (contacts.length === 1) {
                return "file:///tmp/%1.vcf".arg(contacts[0].displayLabel.label.replace(/\s/g, ''))
            } else {
                return "file:///tmp/ubuntu_contacts.vcf";
            }
        }

        Connections {
            target: root.contactModel

            onExportCompleted: {
                // send contacts back to source app (pick mode)
                if (error === ContactModel.ExportNoError) {
                    var obj = Qt.createQmlObject("import Ubuntu.Content 1.3;  ContentItem { url: '" + url + "' }", root)
                    if (root.activeTransfer) {
                        root.activeTransfer.items = [obj]
                        root.activeTransfer.state = ContentTransfer.Charged
                    } else {
                        console.error("No active transfer")
                    }
                } else {
                    root.activeTransfer = ContentHub.ContentTransfer.Aborted
                    console.error("Fail to export contacts:" + error)
                }
                root.dismissBusyDialog()
                root.done(url)
            }

            onContactsFetched: {
                // currentQueryId == -2 is used during a fetch using "memory" manager
                if ((priv.currentQueryId == -2) || (requestId == priv.currentQueryId)) {
                    if (root.exportToDisk) {
                        var contacts = []
                        // remove unnecessary info from contacts
                        for(var i=0; i < fetchedContacts.length; i++) {
                            contacts.push(priv.filterContactDetails(fetchedContacts[i]))
                        }
                        // update outputFile with a friendly name
                        var outputFile = priv.generateOutputFileName(contacts)
                        root.contactModel.exportContacts(outputFile,
                                                         [],
                                                         contacts)
                    }
                    root.contactsFetched(fetchedContacts)
                    priv.currentQueryId = -1
                }
            }
        }

        Connections {
            target: root.activeTransfer

            onStateChanged: {
                if (root.activeTransfer.state === ContentTransfer.Aborted) {
                    root.activeTransfer = null
                    root.done("")
                }
            }
        }
    }
}
