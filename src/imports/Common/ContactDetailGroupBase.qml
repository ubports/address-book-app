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

FocusScope {
    id: root

    readonly property alias detailDelegates: contents.children
    readonly property int detailsCount: detailsModel.count

    property alias contact: detailsModel.contact
    property alias detailType: detailsModel.detailType
    property alias showEmpty: detailsModel.showEmpty

    property variant inputFields: []
    property variant fields
    property string title: null
    property alias headerDelegate: headerItem.sourceComponent
    property Component detailDelegate
    property int minimumHeight: 0
    property bool loaded: false

    signal newFieldAdded(var index)

    implicitHeight: detailsCount > 0 ? contents.implicitHeight : minimumHeight
    visible: implicitHeight > 0

    // This model is used to avoid rebuild the repeater every time that the details change
    // With this model the changed info on the fields will remain after add a new field
    ListModel {
        id: detailsModel

        property QtObject contact: null
        property int detailType: -1
        property bool showEmpty: true
        property variant contactDetails: []

        property QtObject _lastContact: null
        property int _lastDetailType: -1
        property bool _lastShowEmpty: true
        property variant allContactDetails: contact ? contact.contactDetails : []

        function reload() {
            if ((contact != _lastContact) ||
                (detailType != _lastDetailType) ||
                (showEmpty != _lastShowEmpty)) {
                clear()
                root.inputFields = []

                _lastContact = contact
                _lastDetailType = detailType
                _lastShowEmpty = showEmpty
            }

            if ((contact != null) && (detailType != -1)) {
                contactDetails = contact.details(detailType)
            }
            refresh(contactDetails)
        }

        function filterDetails(details) {
            var result = []
            for(var d in details) {
                var isEmpty = true
                for(var f in root.fields) {
                    var fieldValue = details[d].value(root.fields[f])
                    if (fieldValue && (String(fieldValue) !== "")) {
                        isEmpty = false
                        break;
                    }
                }
                if (!isEmpty) {
                    result.push(details[d])
                }
            }
            return result
        }

        function refresh(details) {
            var values = details
            if (!showEmpty)  {
                values = filterDetails(details)
            }

            var diff = count - values.length
            for(var i=0; i < diff; i++) {
                remove(count - 1)
            }

            var modelCount = count
            for(var i=0; i < values.length; i++) {
                var detailObj = values[i]
                if (modelCount <= i) {
                    append({"detail": detailObj})
                } else {
                    set(i, {"detail": detailObj})
                }
            }
        }

        onShowEmptyChanged: reload()
        onDetailTypeChanged: reload()
        onContactChanged: reload()
        onAllContactDetailsChanged: reload()
    }

    Column {
        id: contents

        anchors {
            left: parent.left
            right: parent.right
        }

        Loader {
            id: headerItem
        }

        Repeater {
            id: detailFields

            model: detailsModel

            Loader {
                id: detailItem

                focus: true
                sourceComponent: root.detailDelegate
                Binding {
                    target: detailItem.item
                    property: "detail"
                    value: model.detail
                }

                Binding {
                    target: detailItem.item
                    property: "index"
                    value: index
                }

                onStatusChanged: {
                    if (status === Loader.Ready) {
                        var newFields = root.inputFields
                        newFields.push(detailItem.item)
                        root.newFieldAdded(detailItem.item)
                        root.inputFields = newFields
                        if (item.focus && root.loaded) {
                            item.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: root.loaded = true
}
