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
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtContacts 5.0 as QtContacts

import "../Common"

ContactDetailGroupWithTypeBase {
    id: root

    property QtObject availabelActions
    signal actionTrigerred(string action, QtObject contact)

    headerDelegate: ListItem.Header {
        text: root.title
    }

    detailDelegate: ContactDetailWithTypeView {
        property variant detailType: detail && root.contact && root.typeModel ? root.getType(detail) : null

        availabelActions: root.availabelActions
        contact: root.contact
        fields: root.fields
        subtitle.text: detailType ? detailType.label : ""
        defaultIcon: detailType && detailType.icon ? detailType.icon : ""

        height: implicitHeight
        width: root.width
        onActionTrigerred: root.actionTrigerred(action, contact)
    }
}
