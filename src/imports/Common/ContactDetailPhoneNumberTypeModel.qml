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
        if (detail.contexts.indexOf(QtContacts.ContactDetail.ContextHome) > -1) {
            return 0
        } else if (detail.contexts.indexOf(QtContacts.ContactDetail.ContextWork) > -1) {
            return 1
        } else if (detail.subTypes.indexOf(QtContacts.PhoneNumber.Mobile) > -1) {
            return 3
        } else {
            return 2
        }
    }

    function isNotAModelValue(value) {
        for(var i=0; i < count; i++) {
            if (value === get(i).value) {
                return false
            }
        }
        return true
    }

    function updateDetail(detail, index) {
        var modelData = get(index)
        if (!modelData) {
            return
        }

        var newSubTypes = detail.subTypes.filter(isNotAModelValue)
        var newContext = detail.contexts.filter(isNotAModelValue)

        if (modelData.value === QtContacts.PhoneNumber.Mobile) {
            newSubTypes.push(modelData.value)
        } else {
            newContext.push(modelData.value)
        }

        detail.contexts = newContext
        detail.subTypes = newSubTypes
    }

    Component.onCompleted: {
        append({"value": QtContacts.ContactDetail.ContextHome, "label": i18n.tr("Home"), icon: null})
        append({"value": QtContacts.ContactDetail.ContextWork, "label": i18n.tr("Work"), icon: null})
        append({"value": QtContacts.ContactDetail.ContextOther, "label": i18n.tr("Other"), icon: null})
        append({"value": QtContacts.PhoneNumber.Mobile, "label": i18n.tr("Mobile"), icon: null})
        loaded()
    }
}
