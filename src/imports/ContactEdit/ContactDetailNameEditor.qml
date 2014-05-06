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

import QtQuick 2.2
import Ubuntu.Components 0.1
import QtContacts 5.0 as QtContacts

import "../Common"

ContactDetailItem {
    id: root

    property bool isEmpty: (fields == -1) || (emptyFields.length === fields.length)
    property variant emptyFields: []

    function isEmpty() {
        return false
    }

    function save() {
        var changed = false;

        for(var i=0; i < fieldDelegates.length; i++) {
            var delegate = fieldDelegates[i]

            // Get item from Loader
            if (delegate.item) {
                delegate = delegate.item
            }

            if (delegate.detail && (delegate.field >= 0)) {
                if (delegate.text != delegate.detail.value(delegate.field)) {
                    delegate.detail.setValue(delegate.field, delegate.text)
                    changed  = true;
                }
            }
        }

        return changed
    }

    detail: root.contact ? root.contact.name : null
    fields: [ QtContacts.Name.FirstName, QtContacts.Name.LastName ]

    fieldDelegate: TextInputDetail {
        id: textInputDetail
        objectName: detailToString(QtContacts.ContactDetail.Name, field)

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

        width: root.width - units.gu(4)
        x: units.gu(2)
        detail: root.detail
        height: units.gu(4)
        placeholderText: field == QtContacts.Name.FirstName ? i18n.tr("First name") : i18n.tr("Last name")
        inputMethodHints: Qt.ImhNoPredictiveText
        onTextChanged: checkIsEmpty()
        onFieldChanged: checkIsEmpty()

        //style
        font.pixelSize: FontUtils.sizeToPixels("x-large")
    }
}
