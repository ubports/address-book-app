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
import Ubuntu.Components 0.1
import QtContacts 5.0

import "../Common"

ContactDetailBase {
    id: root

    function save() {
        // only changes the target sync for new contacts
        if (!isNewContact) {
            return;
        }

        var activeSource = getSelectedSource()
        if (!root.detail) {
            root.detail = root.contact.syncTarget
        }
        root.detail.syncTarget = activeSource
    }

    function getSelectedSource() {
        return sourceModel.contacts[sources.selectedIndex].guid.guid
    }

    property bool isNewContact: contact && contact.contactId === "qtcontacts:::"

    detail: contact ? contact.detail(ContactDetail.SyncTarget) : null
    implicitHeight: isNewContact ? units.gu(5) : 0

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

    OptionSelector {
        id: sources

        anchors.fill: parent
        model: sourceModel
        delegate: OptionSelectorDelegate {
            text: contact.displayLabel.label
        }

        containerHeight: itemHeight * 4
    }
    z: 1000
}

