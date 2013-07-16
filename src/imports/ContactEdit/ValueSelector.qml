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

FocusScope {
    id: root

    property alias values: listView.model
    property alias currentIndex: listView.currentIndex
    readonly property bool expanded: activeFocus
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

    focus: true

    Item {

        visible: !root.activeFocus
        anchors.fill: parent

        Label {
            id: label

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: contentWidth

            text: root.values[root.currentIndex]

            // style
            fontSize: "small"
            color: "#f3f3e7"
        }

        Label {
            id: arrowIndicator

            anchors {
                verticalCenter: parent.verticalCenter
                left: label.right
            }
            width: units.gu(2)
            horizontalAlignment: Text.AlignHCenter
            text: ">"

            // style
            fontSize: "small"
            color: "#f3f3e7"
            opacity: 0.2
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.forceActiveFocus()
        }
    }

    ListView {
        id: listView

        anchors.fill: parent
        orientation: ListView.Horizontal
        visible: root.activeFocus

        delegate: Item {
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: arrow.width + listLabel.paintedWidth// + units.gu(2)

            Label {
                id: arrow

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                width: visible ? units.gu(2) : 0
                text: ">"
                horizontalAlignment: Text.AlignHCenter
                visible: index > 0

                // style
                fontSize: "small"
                color: "#f3f3e7"
                opacity: 0.2
            }
            Label {
                id: listLabel

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: arrow.right
                    right: parent.right
                }
                text: modelData

                // style
                fontSize: "small"
                color: "#f3f3e7"
                opacity: currentIndex == index ? 1.0 : 0.2

                MouseArea {
                    anchors.fill: parent
                    onClicked: currentIndex = index
                }
            }
        }
    }
}
