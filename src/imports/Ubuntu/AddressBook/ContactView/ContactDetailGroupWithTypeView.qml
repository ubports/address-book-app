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

import QtQuick 2.2
import QtContacts 5.0 as QtContacts

import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

import Ubuntu.AddressBook.Base 0.1

ContactDetailGroupWithTypeBase {
    id: root

    property QtObject defaultAction: null
    signal actionTrigerred(string actionName, QtObject detail)

    showEmpty: false
    headerDelegate: ListItem.Empty {
        highlightWhenPressed: false

        divider.anchors.leftMargin: units.gu(2)
        divider.anchors.rightMargin: units.gu(2)
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

        Connections {
            target: root.defaultAction
            onTriggered: root.actionTrigerred(root.defaultAction.name, detail)
        }
    }
}
