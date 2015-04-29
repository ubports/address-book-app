/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components 1.1
import QtContacts 5.0
import Ubuntu.Contacts 0.1

ContactDetailGroupWithTypeView {
    id: root

    // does not show the field if there is only one addressbook
    function filterDetails(details) {
        var result = []

        if (sourceModel.contacts.length <= 1) {
            return result;
        }

        for(var d in details) {
            var isEmpty = true
            for(var f in root.fields) {
                var fieldValue = details[d].value(root.fields[f])
                if (fieldValue && (String(fieldValue) !== "")) {
                    isEmpty = false
                    break;
                }
            }
            if (!isEmpty) {
                result.push(details[d])
            }
        }
        return result
    }

    title: i18n.dtr("address-book-app", "Addressbook")
    defaultIcon: "image://theme/contact-group"
    detailType: ContactDetail.SyncTarget
    typeModel: null

    fields: [ SyncTarget.SyncTarget ]

    ContactModel {
        id: sourceModel

        manager: (typeof(QTCONTACTS_MANAGER_OVERRIDE) !== "undefined") && (QTCONTACTS_MANAGER_OVERRIDE != "") ? QTCONTACTS_MANAGER_OVERRIDE : "galera"
        filter:  DetailFilter {
            detail: ContactDetail.Type
            field: Type.TypeField
            value: Type.Group
            matchFlags: DetailFilter.MatchExactly
        }
        autoUpdate: false
    }

    Component.onCompleted: sourceModel.update()
}
