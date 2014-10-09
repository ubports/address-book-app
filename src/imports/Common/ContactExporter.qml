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
import Ubuntu.Content 1.1

Item {
    id: root

    property var contactModel
    property var outputFile
    property var activeTransfer: null

    signal contactsFetched(var contacts)
    signal done()

    function start(contacts) {
        if (!contactModel) {
            console.error("No contact model defined")
            return
        }

        // skip if a query is running
        if (priv.currentQueryId != -1) {
            completed(0)
            return
        }

        var ids = []
        for (var i=0; i < contacts.length; i++) {
            ids.push(contacts[i].contactId)
        }
        if (ids.length == 0) {
            completed(0)
        } else {
            priv.currentQueryId = contactModel.fetchContacts(ids)
        }
    }

    Item {
        id: priv

        property int currentQueryId: -1
        readonly property var detailsBlackList: [ ContactDetail.Favorite, ContactDetail.Tag ]

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
                priv.currentQueryId = -1

                // send contacts back to source app (pick mode)
                if (error === ContactModel.ExportNoError) {
                    var obj = Qt.createQmlObject("import Ubuntu.Content 1.1;  ContentItem { url: '" + url + "' }", root)
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
                root.done()
            }

            onContactsFetched: {
                // currentQueryId == -2 is used during a fetch using "memory" manager
                if ((priv.currentQueryId == -2) || (requestId == priv.currentQueryId)) {
                    if (root.outputFile !== "") {
                        var contacts = []
                        // remove unnecessary info from contacts
                        for(var i=0; i < fetchedContacts.length; i++) {
                            contacts.push(priv.filterContactDetails(fetchedContacts[i]))
                        }
                        // update outputFile with a friendly name
                        root.outputFile = priv.generateOutputFileName(contacts)

                        root.contactModel.exportContacts(root.outputFile,
                                                         [],
                                                         contacts)
                    }
                    root.contactsFetched(fetchedContacts)
                }
            }
        }

        Connections {
            target: root.activeTransfer

            onStateChanged: {
                if (root.activeTransfer.state === ContentTransfer.Aborted) {
                    root.activeTransfer = null
                    root.done()
                }
            }
        }
    }
}
