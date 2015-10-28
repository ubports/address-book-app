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
        } else if (contexts.indexOf(QtContacts.ContactDetail.ContextOther) > -1) {
            return 4
        } else {
            // phone without context and voice type is other
            if (subTypes && subTypes.indexOf(QtContacts.PhoneNumber.Voice) > -1) {
                return 4
            } else if (subTypes && subTypes.indexOf(QtContacts.PhoneNumber.Mobile) > -1) {
                return 2
            } else {
                return 2 // Default value is "Mobile"
            }
        }
    }

    function compareList(listA, listB) {
        if (!listA && !listB) {
            return true
        }

        if (!listA || !listB) {
            return false
        }

        if (listA.length !== listB.length) {
            return false
        }
        for(var i=0; i < listA.length; i++) {
            if (listA[i] !== listB[i]) {
                return false
            }
        }
        return true
    }

    function updateDetail(detail, index) {
        var modelData = get(index)
        if (!modelData) {
            return false
        }

        var newSubTypes = []
        var newContext = []

        if (modelData.context !== -1) {
            newContext.push(modelData.context)
        }
        newSubTypes.push(modelData.subType)

        var changed  = false
        if (!compareList(newContext, detail.contexts)) {
            detail.contexts = newContext
            changed = true
        }

        if (!compareList(newSubTypes, detail.subTypes)) {
            detail.subTypes = newSubTypes
            changed = true
        }
        return changed
    }

    Component.onCompleted: {
        append({"value": "Home",
                // TRANSLATORS: This refers to home landline phone label
                "label": i18n.dtr("address-book-app", "Home"), "icon": null,
                "context": QtContacts.ContactDetail.ContextHome, "subType": QtContacts.PhoneNumber.Voice })
        append({"value": "Work",
                // TRANSLATORS: This refers to landline work phone label
                "label": i18n.dtr("address-book-app", "Work"), "icon": null,
                "context": QtContacts.ContactDetail.ContextWork, "subType": QtContacts.PhoneNumber.Voice })
        append({"value": "Mobile",
                // TRANSLATORS: This refers to mobile/cellphone phone label
                "label": i18n.dtr("address-book-app", "Mobile"), "icon": null,
                "context": -1, "subType": QtContacts.PhoneNumber.Mobile })
        append({"value": "Mobile-Work",
                // TRANSLATORS: This refers to mobile/cellphone work phone label
                "label": i18n.dtr("address-book-app", "Work Mobile"), "icon": null,
                "context": QtContacts.ContactDetail.ContextWork, "subType": QtContacts.PhoneNumber.Mobile })
        append({"value": "Other",
                // TRANSLATORS: This refers to any other phone label
                "label": i18n.dtr("address-book-app", "Other"), "icon": null,
                "context": QtContacts.ContactDetail.ContextOther, "subType": QtContacts.PhoneNumber.Voice })
        loaded()
    }
}
