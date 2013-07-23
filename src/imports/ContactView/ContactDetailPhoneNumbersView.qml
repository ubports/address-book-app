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
import Ubuntu.Components 0.1

import "../Common"

ContactDetailGroupWithTypeView {
    id: root

    detailType: QtContacts.ContactDetail.PhoneNumber
    fields: [ QtContacts.PhoneNumber.Number ]

    title: i18n.tr("Phone")
    typeModel: ContactDetailPhoneNumberTypeModel { }
    defaultAction: Action {
        text: i18n.tr("Favorite")
        iconSource: "artwork:/contact-call.png"
    }

    detailDelegate: ContactDetailPhoneNumberView {
        property variant detailType: detail && root.contact && root.typeModel ? root.getType(detail) : null
        property bool isPreffered: root.contact && root.contact.preferredDetails && root.contact.isPreferredDetail("TEL", detail)

        action: Action {
            text: i18n.tr("Favorite")
            iconSource: contact.favorite.favorite && isPreffered ? "artwork:/favorite-selected.png" : "artwork:/favorite-unselected.png"
        }
        contact: root.contact
        fields: root.fields
        typeLabel: detailType ? detailType.label : ""

        height: implicitHeight
        width: root.width
        onClicked: {
            if (isPreffered && contact.favorite.favorite) {
                contact.favorite.favorite = false
            } else {
                root.contact.setPreferredDetail("TEL", detail)
                contact.favorite.favorite = true
            }
            contact.save()
        }
    }
}
