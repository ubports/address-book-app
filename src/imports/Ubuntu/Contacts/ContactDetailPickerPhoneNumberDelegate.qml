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
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtContacts 5.0
Item {
    property QtObject contact: null

    height: details.height
    anchors.left:parent.left
    anchors.right:parent.right
    anchors.leftMargin: units.gu(2)
    anchors.rightMargin: units.gu(2)

    signal detailClicked(QtObject detail)

    Column {
        id: details
        anchors.top: parent.top
        height: childrenRect.height
        width: parent.width

        Repeater {
            model: contact ? contact.phoneNumbers : undefined
            ListItem.Empty {
                removable: false
                Text {
                    id: context
                    anchors.top: parent.top
                    text: {
                        // TODO: check if we have more than one context
                        switch(contexts[0]) {
                        case ContactDetail.ContextHome: "Home"; break;
                        case ContactDetail.ContextWork: "Work"; break;
                        case ContactDetail.ContextWork: "Other"; break;
                        }
                    }
                    color: "grey"
                }
                Text {
                    anchors.top: context.bottom
                    text: number
                    color: "white"
                }

                onClicked: detailClicked(contact.phoneNumbers[index])
            }
        }
    }
}
