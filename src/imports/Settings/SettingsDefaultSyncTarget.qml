/*
* Copyright (C) 2015 Canonical, Ltd.
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

Empty {
   id: root

   signal changed()

   function update()
   {
       sourceModel.update()
   }

   function save()
   {
       var changed = false
       var selectedSource = getSelectedSource()
       if (!selectedSource) {
           return
       }

       var details = selectedSource.details(ContactDetail.ExtendedDetail)
       for(var d in details) {
           if (details[d].name === "IS-PRIMARY") {
               if (!details[d].data) {
                   details[d].data = true
                   changed = true
                   break
               }
           }
       }
       if (changed) {
           sourceModel.saveContact(selectedSource)
       }
   }

   function getSelectedSource() {
       if (sources.model.count <= 0)
           return -1

       return sources.model.get(sources.selectedIndex).source
   }

   height: sources.currentlyExpanded ?
              sources.containerHeight + units.gu(6) + label.height :
              sources.itemHeight + units.gu(6) + label.height

   ContactModel {
       id: sourceModel

       manager: (typeof(QTCONTACTS_MANAGER_OVERRIDE) !== "undefined") && (QTCONTACTS_MANAGER_OVERRIDE != "") ?
                    QTCONTACTS_MANAGER_OVERRIDE : "org.nemomobile.contacts.sqlite"
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
           sources._notify = false

           clear()
           // filter out read-only sources
           var contacts = sourceModel.contacts
           if (contacts.length === 0) {
               return
           }

           var data = []
           for(var i in contacts) {
               var sourceMetaData = getSourceMetaData(contacts[i])
               if (!sourceMetaData['readOnly']) {
                   data.push({'sourceId': contacts[i].guid.guid,
                              'sourceName': contacts[i].displayLabel.label,
                              'accountId': sourceMetaData['account-id'],
                              'accountProvider': sourceMetaData['account-provider'],
                              'readOnly': sourceMetaData['read-only'],
                              'isPrimary': sourceMetaData['is-primary'],
                              'source': contacts[i]
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

            sources.selectedIndex = 0
           var primaryIndex = 0
           for (var i in data) {
               if (data[i].isPrimary) {
                   primaryIndex = i
               }
               append(data[i])
           }

           // select primary account
           sources.selectedIndex = primaryIndex
           sources._notify = true
       }
   }

   Label {
       id: label

       text: i18n.tr("Default address book")
       anchors {
           left: parent.left
           top: parent.top
           right: parent.right
           margins: units.gu(2)
       }
       height: units.gu(4)
   }

   OptionSelector {
       id: sources
       property bool _notify: true

       model: writableSources
       anchors {
           left: parent.left
           leftMargin: units.gu(2)
           top: label.bottom
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
       onSelectedIndexChanged: {
           if (_notify && selectedIndex >= 0) {
               root.changed()
           }
       }
   }

   // In case of sources changed we need to update the model
   Connections {
       target: application
       onSourcesChanged: root.update()
   }
}

