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

    property Action defaultAction
    signal actionTrigerred(string action, QtObject detail)

    showEmpty: false
    headerDelegate: ListItem.Empty {
        highlightWhenPressed: false

        width: root.width
        height: units.gu(5)
        Label {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            text: root.title

            // style
            fontSize: "medium"
            color: "#f3f3e7"
            opacity: 0.2
        }
    }

    detailDelegate: ContactDetailWithTypeView {
        property variant detailType: detail && root.contact && root.typeModel.ready ? root.getType(detail) : null

        action: root.defaultAction
        contact: root.contact
        fields: root.fields
        typeLabel: detailType ? detailType.label : ""
        typeIcon: detailType && detailType.icon ? detailType.icon : ""

        height: implicitHeight
        width: root.width
        onClicked: root.actionTrigerred(action, detail)
    }
}
