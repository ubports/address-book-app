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

ContactDetailGroupWithAction {
    function getTypeIndex(detail) {
        if (detail.contexts.indexOf(QtContacts.ContactDetail.ContextHome) > -1) {
            return 1
        } else if (detail.contexts.indexOf(QtContacts.ContactDetail.ContextWork) > -1) {
            return 2
        } else if (detail.subTypes.indexOf(QtContacts.ContactPhoneNumber.Mobile) > -1) {
            return 0
        } else {
            return 3
        }
    }


    title: i18n.tr("Phone")
    details: contactEditor.contact ? contactEditor.contact.phoneNumbers : null
    fields: [ QtContacts.PhoneNumber.Number ]
    defaultIcon: "artwork:/contact-call.png"
    typeModel: ListModel {
        Component.onCompleted: {
            append({"value": "Mobile", "label": i18n.tr("Mobile"), icon: null})
            append({"value": "Home", "label": i18n.tr("Home"), icon: null})
            append({"value": "Work", "label": i18n.tr("Work"), icon: null})
            append({"value": "Other", "label": i18n.tr("Other"), icon: null})
        }
    }
}
