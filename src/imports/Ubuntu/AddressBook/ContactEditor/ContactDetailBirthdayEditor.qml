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
import Ubuntu.Components.Pickers 1.3
import QtContacts 5.0 as QtContact
import Ubuntu.Contacts 0.1

import Ubuntu.AddressBook.Base 0.1

//style
import Ubuntu.Components.Themes.Ambiance 0.1

ContactDetailBase {
    id:root
    property date date
    property date originalValue
    property bool newBirthdayRequested: false

    detail: root.contact ? root.contact.birthday :  null

    implicitHeight: contents.height
    anchors.leftMargin: units.gu(2)
    anchors.rightMargin: units.gu(2)

    visible: !isEmpty() || newBirthdayRequested
    //activeFocusOnTab: false

    onDetailChanged: {
        if (detail && isDateValid(detail.birthday)) {
                root.date = new Date(detail.birthday.getTime())
                root.originalValue = root.date
        }
    }

    function isDateValid(dt) {
        return dt instanceof Date && !isNaN(dt.valueOf())
    }


    function isEmpty() {
        return input.text.length == 0
    }

    function save() {
        var detailchanged  = false
        if (isDateValid(root.date)) {
            if (input.text.length == 0) {
                root.detail.setValue(QtContact.Birthday, "")
                detailchanged  = true
            }else {
                var dt = new Date(root.date.getTime())
                if (!isDateValid(originalValue) || originalValue.getTime() !== dt.getTime()) {
                    root.detail.setValue(QtContact.Birthday,dt)
                    detailchanged  = true
                }
            }

        }
        return detailchanged
    }

    function selectDate(){
        if (!isDateValid(root.date)) {
            var dt = new Date()
            dt.setFullYear(dt.getFullYear()-30)
            dt.setHours(0,0,0,0)
            root.date = dt
        }

        var pickerPanel = PickerPanel.openDatePicker(root, "date", "Years|Months|Days")
        if ( pickerPanel!=null) {
            var picker = pickerPanel.picker
            var dmax = new Date()
            picker.maximum = dmax
            var dmin = new Date()
            dmin.setFullYear(dmax.getFullYear()-110)
            picker.minimum = dmin
        }
    }

    Column {
        id: contents
        spacing: units.gu(1)
        width: parent.width

        Label {
            id: header

            width: root.width - units.gu(4)
            height: units.gu(4)
            text: i18n.dtr("address-book-app", "Birthday")
            // style
            fontSize: "medium"
            verticalAlignment: Text.AlignVCenter
            ThinDivider {
                anchors.bottom: parent.bottom
            }
        }


        TextField {
            id: input
            text:  Qt.formatDate(root.date)

            anchors {
                left: parent.left
                right: parent.right
                topMargin: units.gu(2)
                bottomMargin: units.gu(2)
            }
            height: units.gu(4)

            placeholderText: i18n.dtr("address-book-app", "Enter a birthday")
            style: TextFieldStyle {
                overlaySpacing: 0
                frameSpacing: 0
                background: Item {}
            }

            MouseArea {
                anchors.fill: parent
                onClicked: selectDate()
            }

            AbstractButton {
                id: clearButton
                objectName: "clear_button"
                activeFocusOnPress: false
                activeFocusOnTab: false

                anchors {
                    top: parent.top
                    right: parent.right
                    margins: units.gu(0.5)
                    verticalCenter: parent.verticalCenter

                }
                /* draggedItemMouseArea and dragger in TextCursor are reparented to the
                   TextField and end up being on top of the clear button.
                   Ensure that the clear button receives touch/mouse events first.
                */
                z: 100
                width: visible ? icon.width : 0

                Icon {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    width: units.gu(2.5)
                    height: width
                    // use icon from icon-theme
                    name: "edit-clear"
                }

                onClicked: {
                    input.text = ""
                }
            }
        }

    }

    Connections {
        target: addNewFieldButton
        onFieldSelected: {
            if (qmlTypeName=="Birthday") {
                newBirthdayRequested = true
                input.text = Qt.binding(function() { return Qt.formatDate(root.date)})
                selectDate()
            }
        }
    }

}
