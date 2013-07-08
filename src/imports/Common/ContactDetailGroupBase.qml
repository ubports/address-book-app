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

    readonly property variant details : contact && detailType ? contact.details(detailType) : []
    readonly property alias detailDelegates: contents.children

    property QtObject contact: null
    property int detailType: 0
    property variant fields
    property string title: null
    property alias headerDelegate: headerItem.sourceComponent
    property Component detailDelegate
    property int minimumHeight: 0


    implicitHeight: root.details.length > 0 ? contents.height + units.gu(1) : minimumHeight
    visible: implicitHeight > 0

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

            model: root.details.length
            Loader {
                id: detailItem

                sourceComponent: root.detailDelegate
                Binding {
                    target: detailItem.item
                    property: "detail"
                    value: root.details[index]
                }

                Connections {
                    target: root
                    onDetailsChanged: detailItem.item.detail = root.details[index]
                }

                Connections {
                    target: root.contact
                    onContactChanged: detailItem.item.detail = root.details[index]
                }
            }
        }
    }

    ListItem.ThinDivider {
        anchors.bottom: parent.bottom
    }
}
