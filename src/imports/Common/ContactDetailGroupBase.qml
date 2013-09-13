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

    readonly property variant details: contact && contact.contactDetails && detailType ? contact.details(detailType) : []
    readonly property alias detailDelegates: contents.children

    property QtObject contact: null
    property int detailType: 0
    property variant fields
    property string title: null
    property alias headerDelegate: headerItem.sourceComponent
    property Component detailDelegate
    property int minimumHeight: 0
    property bool loaded: false

    implicitHeight: root.details.length > 0 ? contents.height : minimumHeight
    visible: implicitHeight > 0

    // This model is used to avoid rebuild the repeater every time that the details change
    // With this model the changed info on the fields will remain after add a new field
    ListModel {
        id: detailsModel

        property var values: root.details

        onValuesChanged: {
            if (!values) {
                clear()
                root.loaded = false
                return
            }

            while (count > values.length) {
                remove(count - 1)
            }

            var modelCount = count

            for(var i=0; i < values.length; i++) {
                if (modelCount < i) {
                    append({"detail": values[i]})
                } else if (get(i) != values[i]) {
                    set(i, {"detail": values[i]})
                }
            }

            if (!root.loaded) {
                loadTimer.restart()
            }
        }
    }

    Column {
        id: contents

        anchors {
            left: parent.left
            right: parent.right
        }

        height: childrenRect.height
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
                    value: root.details[index]
                }
            }

            onItemAdded: {
                if (root.loaded) {
                    item.forceActiveFocus()
                }
            }

        }
    }

    // This timer will help to avoid fields get focus during the page creation
    // At the first time that the page is loaded the timer will start and all
    // subsequent details added before the timeout would not receive focus,
    // after the timeout the new fields will receive focus as default
    Timer {
        id: loadTimer

        interval: 500
        onTriggered: root.loaded = true
    }
}
