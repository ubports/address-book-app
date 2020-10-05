/*
 * Copyright (C) 2020 UBports Foundation.
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
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import QtContacts 5.0 as QtContacts

import Ubuntu.AddressBook.Base 0.1


ContactDetailBase {
    id: root

    property string date : detail && isDateValid(detail.birthday) ? Qt.formatDate(detail.birthday) : ""

    detail: contact ? contact.birthday : null

    activeFocusOnTab: false
    anchors.leftMargin: units.gu(2)
    anchors.rightMargin: units.gu(2)
    visible: implicitHeight > 0
    implicitHeight:(date.length > 0) ? contents.implicitHeight : 0

    function isDateValid(dt) {
        return dt instanceof Date && !isNaN(dt.valueOf())
    }


    Column {
        id: contents
        spacing: units.gu(1)
        width: parent.width


        Label {
            id: header

            width: root.width
            height: units.gu(4)
            text: i18n.dtr("address-book-app", "Birthday")
            // style
            fontSize: "medium"
            verticalAlignment: Text.AlignVCenter
            ThinDivider {
                anchors.bottom: parent.bottom
            }
        }


        Rectangle {

            height: childrenRect.height
            anchors {
                left: parent.left
                right: parent.right
            }
            color: theme.palette.normal.background

            Label {
                id: label
                anchors.left: parent.left
                height: units.gu(3)
                fontSize: "medium"
                text: root.date
            }

            Icon {
                id: icon

                anchors.right: parent.right
                anchors.rightMargin: units.gu(1)
                width: units.gu(2.5)
                height: width
                name: "calendar"
                color: root.activeFocus ? theme.palette.normal.focus : theme.palette.normal.baseText
                asynchronous: true
            }
        }


    }

    onClicked: {
        var bdayDate =  new Date(root.detail.birthday);
        bdayDate.setFullYear(new Date().getFullYear())
        Qt.openUrlExternally("calendar:///startdate=%1".arg(bdayDate.toISOString()))
    }



}
