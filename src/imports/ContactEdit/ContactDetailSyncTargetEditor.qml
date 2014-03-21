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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "../Common"

ContactDetailBase {
    id: root

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
        var selectedContact = sourceModel.contacts[sources.selectedIndex]
        if (selectedContact) {
            return selectedContact.guid.guid
        } else {
            return -1
        }
    }

    property bool isNewContact: contact && contact.contactId === "qtcontacts:::"
    property real myHeight: sources.containerHeight + units.gu(4) + label.height

    detail: contact ? contact.detail(ContactDetail.SyncTarget) : null
    implicitHeight: isNewContact ? myHeight : 0

    ContactModel {
        id: sourceModel

        manager: QTCONTACTS_MANAGER_OVERRIDE && QTCONTACTS_MANAGER_OVERRIDE != "" ? QTCONTACTS_MANAGER_OVERRIDE : "galera"
        filter:  DetailFilter {
            detail: ContactDetail.Type
            field: Type.TypeField
            value: Type.Group
            matchFlags: DetailFilter.MatchExactly
        }
    }

    Label {
        id: label

        text: i18n.tr("Addressbook")
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            margins: units.gu(2)
        }
        height: root.active ? units.gu(4) : units.gu(3)
    }

    OptionSelector {
        id: sources

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: label.bottom
            topMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(2)
        }

        model: sourceModel
        delegate: OptionSelectorDelegate {
            text: contact.displayLabel.label
            height: units.gu(5)
        }

        containerHeight: sourceModel.contacts.length > 4 ? itemHeight * 4 : itemHeight * sourceModel.contacts.length
    }
    z: 1000
}

