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

import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.AddressBook.Base 0.1

ContactDetailGroupWithTypeBase {
    id: root

    property QtObject defaultAction: null
    signal actionTrigerred(string actionName, QtObject detail)

    showEmpty: false
    headerDelegate: Label {
        id: header

        width: root.width - units.gu(4)
        x: units.gu(2)
        height: units.gu(4)
        text: root.title
        // style
        fontSize: "medium"
        verticalAlignment: Text.AlignVCenter
        ThinDivider {
            anchors.bottom: parent.bottom
        }
    }

    detailDelegate: ContactDetailWithTypeView {
        property variant detailType: detail && root.contact && root.typeModelReady ? root.getType(detail) : ""

        action: root.defaultAction
        contact: root.contact
        fields: root.fields
        typeLabel: detailType ? detailType.label : ""

        height: implicitHeight
        width: root.width

        onClicked: root.actionTrigerred(root.defaultAction.name, detail)
    }
}
