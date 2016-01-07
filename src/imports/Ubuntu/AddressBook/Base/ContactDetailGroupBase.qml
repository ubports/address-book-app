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

FocusScope {
    id: root

    property var details: []
    readonly property alias detailDelegates: contents.children
    readonly property int detailsCount: detailsModel.count

    property variant inputFields: []
    property QtObject contact: null
    property int detailType: 0
    property variant fields
    property string title: null
    property alias headerDelegate: headerItem.sourceComponent
    property Component detailDelegate
    property int minimumHeight: 0
    property bool loaded: false
    property bool showEmpty: true

    signal newFieldAdded(int fieldIndex, QtObject field)

    function reloadDetails(clearFields)
    {
        if (clearFields) {
            root.inputFields = []
        }

        if (contact && detailType) {
            root.details = contact.details(detailType)
        } else {
            root.details = []
        }
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

    onContactChanged: reloadDetails(true)
    onDetailTypeChanged: reloadDetails(true)

    Connections {
        target: root.contact
        onContactChanged: reloadDetails(false)
    }

    implicitHeight: detailsCount > 0 ? contents.implicitHeight : minimumHeight
    visible: implicitHeight > 0

    // This model is used to avoid rebuild the repeater every time that the details change
    // With this model the changed info on the fields will remain after add a new field
    ListModel {
        id: detailsModel

        property var values: root.showEmpty && root.details ? root.details : filterDetails(root.details)

        onValuesChanged: {
            if (!values) {
                root.inputFields = []
                clear()
                return
            }

            while (count > values.length) {
                remove(count - 1)
            }

            var modelCount = count
            for(var i=0; i < values.length; i++) {
                if (modelCount <= i) {
                    append({"detail": values[i]})
                } else if (get(i) != values[i]) {
                    set(i, {"detail": values[i]})
                }
            }
        }
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

                        root.inputFields = newFields
                        if (root.loaded) {
                            root.newFieldAdded(detailItem.item, item)
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: root.loaded = true
}
