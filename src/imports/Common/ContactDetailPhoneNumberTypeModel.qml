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
import QtContacts 5.0 as QtContacts

ListModel {
    id: typeModel

    signal loaded()

    function getTypeIndex(detail) {
        var contexts = detail.contexts
        var subTypes = detail.subTypes

        if (contexts.indexOf(QtContacts.ContactDetail.ContextHome) > -1) {
            if (subTypes && subTypes.indexOf(QtContacts.PhoneNumber.Mobile) > -1) {
                return 2
            } else {
                return 0
            }
        } else if (contexts.indexOf(QtContacts.ContactDetail.ContextWork) > -1) {
            if (subTypes && subTypes.indexOf(QtContacts.PhoneNumber.Mobile)> -1) {
                return 3
            } else {
                return 1
            }
        } else{
            return 4
        }
    }

    function updateDetail(detail, index) {
        var modelData = get(index)
        if (!modelData) {
            return
        }

        // WORKAROUND: in EDS empty context is equal to QtContacts.ContactDetail.ContextOther
        // this will avoid call contact update if the context has not changed
        if ((detail.contexts.length === 0) && (modelData.value === "Other")) {
            return
        }

        var newSubTypes = []
        var newContext = []

        newContext.push(modelData.context)
        if (modelData.subType !== -1) {
            newSubTypes.push(modelData.subType)
        }
        // All current labels is voice type
        newSubTypes.push(QtContacts.PhoneNumber.Voice)

        detail.contexts = newContext
        detail.subTypes = newSubTypes
    }

    Component.onCompleted: {
        append({"value": "Home", "label": i18n.tr("Home"), icon: null,
                context: QtContacts.ContactDetail.ContextHome, subType: QtContacts.PhoneNumber.Landline })
        append({"value": "Work", "label": i18n.tr("Work"), icon: null,
               context: QtContacts.ContactDetail.ContextWork, subType: QtContacts.PhoneNumber.Landline })
        append({"value": "Mobile", "label": i18n.tr("Mobile"), icon: null,
                context: QtContacts.ContactDetail.ContextHome, subType: QtContacts.PhoneNumber.Mobile })
        append({"value": "Mobile-Work", "label": i18n.tr("Work Mobile"), icon: null,
                context: QtContacts.ContactDetail.ContextWork, subType: QtContacts.PhoneNumber.Mobile })
        append({"value": "Other", "label": i18n.tr("Other"), icon: null,
                context: QtContacts.ContactDetail.ContextOther, subType: -1 })
        loaded()
    }
}
