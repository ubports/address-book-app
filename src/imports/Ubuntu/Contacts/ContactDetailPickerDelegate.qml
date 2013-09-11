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
import QtContacts 5.0

Item {
    id: detailPickerDelegate

    property string contactId
    property QtObject contact: null
    property int currentOperation: -1
    property int detailType: 0
    property QtObject contactsModel

    signal detailClicked(QtObject contact, QtObject detail)

    width: parent.width
    height: delegateLoader.status == Loader.Ready ? delegateLoader.item.height : 0

    onContactIdChanged: {
        currentOperation = contactsModel.fetchContacts(contactId)
    }

    Connections {
        target: contactsModel
        onContactsFetched: {
            if (currentOperation == requestId) {
                detailPickerDelegate.contact = fetchedContacts[0]
                // TODO: add more types and delegates
                switch(detailType) {
                case ContactDetail.PhoneNumber:
                    delegateLoader.source = Qt.resolvedUrl("ContactDetailPickerPhoneNumberDelegate.qml")
                    break
                default: ""
                }
                delegateLoader.item.contact = contact
            }
        }
    }

    Loader {
        id: delegateLoader
        anchors.left: parent.left
        anchors.right: parent.right
    }

    Connections {
        target: delegateLoader.item
        onDetailClicked: detailClicked(contact, detail)
    }
}
