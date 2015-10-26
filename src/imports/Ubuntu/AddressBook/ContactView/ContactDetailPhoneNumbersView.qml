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

import Ubuntu.Contacts 0.1
import Ubuntu.Components 1.3

ContactDetailGroupWithTypeView {
    id: root

    detailType: QtContacts.ContactDetail.PhoneNumber
    fields: [ QtContacts.PhoneNumber.Number ]

    title: i18n.dtr("address-book-app", "Phone")
    typeModel: ContactDetailPhoneNumberTypeModel { }
    defaultAction: Action {
        text: i18n.dtr("address-book-app", "Phone")
        name: "default"
    }
    detailDelegate: ContactDetailPhoneNumberView {
        property variant detailType: detail && root.contact && root.typeModelReady ? root.getType(detail) : null

        action: root.defaultAction
        contact: root.contact
        fields: root.fields
        typeLabel: detailType ? detailType.label : ""

        height: implicitHeight
        width: root.width

        onActionTrigerred: root.actionTrigerred(actionName, detail)
        onClicked: root.actionTrigerred(root.defaultAction.name, detail)
    }
}
