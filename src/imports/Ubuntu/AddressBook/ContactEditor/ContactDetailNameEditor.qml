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
import QtContacts 5.0

import Ubuntu.Components 1.3

import Ubuntu.AddressBook.Base 0.1

ContactDetailItem {
    id: root

    property variant emptyFields: []
    property bool showMiddleName: (detail && (detail.value(Name.MiddleName) !== undefined))
    readonly property Item middleNameField: showMiddleName ? fieldDelegates[1] : null

    function isEmpty() {
        return (fields == -1) || (emptyFields.length === fields.length)
    }

    function save() {
        var changed = false;
        var names = []
        for(var i=0; i < fieldDelegates.length; i++) {
            var delegate = fieldDelegates[i]

            // Get item from Loader
            if (delegate.item) {
                delegate = delegate.item
            }

            if (delegate.detail && (delegate.field >= 0)) {
                var value = delegate.detail.value(delegate.field)
                names.push(value)
                if (delegate.text != value) {
                    delegate.detail.setValue(delegate.field, delegate.text)
                    changed  = true;
                }
            }
        }

        return changed
    }

    spacing: units.gu(1)
    detail: root.contact ? root.contact.name : null
    fields: [ Name.FirstName, Name.MiddleName, Name.LastName ]
    highlightOnFocus: false

    fieldDelegate: TextInputDetail {
        id: textInputDetail
        objectName: detailToString(ContactDetail.Name, field)

        function checkIsEmpty() {
            if (field == -1) {
                return;
            }

            var newEmtpyFields = root.emptyFields
            var indexOf = newEmtpyFields.indexOf(field)

            if ((text.length > 0) && (indexOf !== -1)) {
                newEmtpyFields.splice(indexOf, 1)
            } else if ((text.length === 0) && (indexOf === -1)){
                newEmtpyFields.push(field)
            }
            root.emptyFields = newEmtpyFields
        }

        function placeholderTextFromField(field)
        {
            switch (field) {
                case Name.FirstName:
                    return i18n.dtr("address-book-app", "First name")
                case Name.MiddleName:
                    return i18n.dtr("address-book-app", "Middle name")
                case Name.LastName:
                    return i18n.dtr("address-book-app", "Last name")
                default:
                    return "";
            }
        }

        focus: true
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
        height: units.gu(4)
        detail: root.detail
        visible: field === Name.MiddleName ? root.showMiddleName : true

        placeholderText: placeholderTextFromField(field)
        inputMethodHints: Qt.ImhNoPredictiveText
        onTextChanged: checkIsEmpty()
        onFieldChanged: checkIsEmpty()

        //style
        font.pixelSize: FontUtils.sizeToPixels("large")
    }
}
