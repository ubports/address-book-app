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
import QtContacts 5.0 as QtContacts

import "../Common"

ContactDetailGroupWithTypeBase {
    id: root

    property string detailQmlTypeName
    property int currentItem: -1
    property int fieldType: QtContacts.ContactDetail.FieldContext

    function save() {
        var changed = false
        for(var i=0; i < detailDelegates.length; i++) {
            var delegate = detailDelegates[i]

            // Get item from Loader
            if (delegate.item) {
                delegate = delegate.item
            }

            if (delegate.save) {
                // save type
                if (updateDetail(delegate.detail, delegate.selectedTypeIndex)) {
                    changed = true
                }

                // save fields
                if (delegate.save()) {
                    changed = true
                }
            }
        }
        return changed
    }

    minimumHeight: units.gu(3)

    headerDelegate: Item {
        id: header
        width: root.width
        height: units.gu(3)

        Label {
            anchors {
                left: parent.left
                top: parent.top
                right: addFieldButton.left
                bottom: parent.bottom
            }
            text: root.title
        }

        AbstractButton {
            id: addFieldButton

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(1)
            }
            width: units.gu(2)
            height: units.gu(2)

            Image {
                anchors.fill: parent
                source: "artwork:/add-detail.png"
                fillMode: Image.PreserveAspectFit
            }

            onClicked: {
                if (detailQmlTypeName) {
                    var newDetail = Qt.createQmlObject("import QtContacts 5.0; " + detailQmlTypeName + "{}", root)
                    if (newDetail) {
                        root.contact.addDetail(newDetail)
                    }
                }
            }
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

        contact: root.contact
        fields: root.fields
        height: implicitHeight
        width: root.width

        onDetailChanged: updateCombo(false)

        Connections {
            target: root.typeModel
            onLoaded: updateCombo(true)
        }
    }
}
