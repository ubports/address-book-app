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
import Ubuntu.Components.Popups 0.1 as Popups

Item {
    id: root

    property variant values: []
    property int currentIndex: -1
    property bool expanded: false
    readonly property alias text: label.text

    function selectItem(text) {
        for(var i=0; i < values.length; i++) {
            if (values[i] == text) {
                currentIndex = i
                return
            }
        }
        currentIndex = -1
    }

    Component {
        id: popoverComponent

        Popups.Popover {
            id: popup

            Component.onCompleted: root.expanded = true
            Component.onDestruction: root.expanded = false
            Column {
                id: body
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }

                Repeater {
                    id: repeater
                    model: root.values

                    ListItem.Standard {
                        width: parent.width
                        text: modelData

                        onClicked: {
                            root.currentIndex = index
                            Popups.PopupUtils.close(popup)
                        }
                    }
                }
            }
        }
    }

    Label {
        id: label

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: button.right
            top: parent.top
            topMargin: units.gu(1)
        }
        text: root.currentIndex >= 0 ? root.values[root.currentIndex] : ""
    }

    AbstractButton {
        id: button

        anchors {
            verticalCenter: label.verticalCenter
            right: parent.right
            rightMargin: units.gu(1)
        }

        width: units.gu(2)
        height: units.gu(2)

        Image {
            anchors.fill: parent
            source: "artwork:/combo-indicator.png"
            fillMode: Image.PreserveAspectFit
            rotation: root.expanded ? 270 : 90
        }
        onClicked: Popups.PopupUtils.open(popoverComponent, button)
    }
}
