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
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Contacts 0.1

import Ubuntu.AddressBook.Base 0.1

ContactDetailGroupWithTypeBase {
    id: root

    property string detailQmlTypeName
    property int currentItem: -1
    property int fieldType: ContactDetail.FieldContext
    property variant placeholderTexts: []
    property int inputMethodHints: Qt.ImhNone
    property variant newDetails: []
    property bool usePhoneFormat: false

    function cancel() {
        for(var i=0; i < root.newDetails.length; i++) {
            root.contact.removeDetail(root.newDetails[i])
        }
        root.newDetails = []
    }

    function isEmpty() {
        for(var i=0; i < detailDelegates.length; i++) {
            var delegate = detailDelegates[i]

            // Get item from Loader
            if (delegate.item) {
                delegate = delegate.item
            }

            if (delegate.isEmpty) {
                if (!delegate.isEmpty()) {
                    return false
                }
            }
        }
        return true
    }

    function save() {
        var changed = false
        var removedDetails = []
        for(var i=0; i < detailDelegates.length; i++) {
            var delegate = detailDelegates[i]

            // Get item from Loader
            if (delegate.item) {
                delegate = delegate.item
            }

            if (delegate.save) {
                // check if was removed
                if (delegate.isEmpty()) {
                    removedDetails.push(delegate.detail)
                    changed = true
                } else {
                    if (updateDetail(delegate.detail, delegate.selectedTypeIndex)) {
                        changed = true
                    }

                    // save field changes
                    if (delegate.save()) {
                        changed = true
                    }
                }
            }
        }

        for(var i=0; i < removedDetails.length; i++) {
            if (contact.isPreferredDetail("TEL", removedDetails[i])) {
                contact.favorite.favorite = false
            }
            contact.removeDetail(removedDetails[i])
        }

        return changed
    }

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

    detailDelegate: ContactDetailWithTypeEditor {
        property variant detailType: null
        property bool comboLoaded: false

        function updateCombo(reload)
        {
            // Does not update the combo info after details change (Ex. a new detail field was created)
            if (!reload && comboLoaded) {
                return;
            }

            if (!root.typeModel) {
                return;
            }

            comboLoaded = true
            var newTypes = []
            for(var i=0; i < root.typeModel.count; i++) {
                newTypes.push(root.typeModel.get(i).label)
            }
            types = newTypes
            if (detail) {
                detailType = getType(detail)
                if (detailType) {
                    selectType(detailType.label)
                }
            }
        }
        placeholderTexts: root.placeholderTexts
        contact: root.contact
        fields: root.fields
        height: implicitHeight
        width: root.width

        inputMethodHints: root.inputMethodHints
        onDetailChanged: updateCombo(false)
        usePhoneFormat: root.usePhoneFormat

        // this is necessary due the default property of ListItem.Empty
        Item {
            Connections {
                target: root.typeModel
                onLoaded: updateCombo(true)
            }
        }
    }
}
