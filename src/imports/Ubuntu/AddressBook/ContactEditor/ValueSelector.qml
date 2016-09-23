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
import Ubuntu.Components 1.3

Item {
    id: root

    property bool readOnly: false
    property bool active: false
    property alias values: listView.model
    property alias currentIndex: listView.currentIndex
    readonly property bool expanded: (state === "expanded") && listView.opacity == 1.0
    readonly property alias text: label.text

    function selectItem(text)
    {
        for(var i=0; i < values.length; i++) {
            if (values[i] == text) {
                currentIndex = i
                return
            }
        }
        currentIndex = -1
    }

    function moveNext()
    {
        if (currentIndex < (values.length-1)) {
            currentIndex++
        } else {
            currentIndex = 0
        }
    }

    function movePrevious()
    {
        if (currentIndex > 0) {
            currentIndex--
        } else {
            currentIndex = values.length - 1
        }
    }
    onExpandedChanged: expanded && timer.start()

    // FIXME: workaround to close list after a while.
    // we cant rely on focus since it hides the keyboard.
    Timer {
        id: timer

        interval: 5000
        running: false
        onTriggered: state = ""
    }

    Item {
        id: title

        anchors {
            top: parent.top
            bottom:  parent.bottom
        }
        Behavior on x {
            UbuntuNumberAnimation { }
        }
        Label {
            id: label

            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: contentWidth

            text: root.currentIndex >= 0 ? root.values[root.currentIndex] : ""

            // style
            fontSize: root.active ? "medium" : "small"
        }

        Icon {
            name: "go-next"
            color: "black"
            height: units.gu(1)
            width: height
            asynchronous: true

            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: units.dp(2)
                left: label.right
                leftMargin: units.gu(0.5)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!readOnly) {
                root.state = "expanded"
                timer.restart()
            }
        }
    }

    ListView {
        id: listView
        objectName: "valuesListView"

        anchors.fill: parent
        clip: true
        orientation: ListView.Horizontal
        visible: !title.visible
        snapMode: ListView.SnapToItem

        delegate: Item {
            objectName: "item_" + index

            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            width: arrow.width + listLabel.paintedWidth + units.gu(1)
            opacity: currentIndex == index ? 1.0 : 0.4

            Label {
                id: listLabel

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                width: paintedWidth
                text: modelData

                // style
                fontSize: "medium"

                MouseArea {
                    width: parent.width + units.gu(0.5)
                    height: parent.height + units.gu(0.5)
                    anchors.centerIn: parent
                    onClicked: {
                        timer.stop()
                        currentIndex = index
                        root.state = ""
                    }
                }
            }

            Icon {
                id: arrow

                name: "go-next"
                height: visible ? units.gu(1) : 0
                width: height
                visible: index < (listView.count - 1)
                asynchronous: true

                anchors {
                    verticalCenter: listLabel.verticalCenter
                    verticalCenterOffset: units.dp(2)
                    left: listLabel.right
                    leftMargin: units.gu(0.5)
                }
            }
        }
    }

    transitions: [
        Transition {
            to: "expanded"
            SequentialAnimation {
                UbuntuNumberAnimation {
                    target: title
                    property: "x"
                    to: (listView.currentItem.x - listView.contentX)
                }
                PropertyAction {
                    target: title
                    property: "visible"
                    value: false
                }
                UbuntuNumberAnimation {
                    target: listView
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                }
            }
        },
        Transition {
            to: ""
            SequentialAnimation {
                UbuntuNumberAnimation {
                    target: listView
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                }
                PropertyAction {
                    target: title
                    property: "visible"
                    value: true
                }
                UbuntuNumberAnimation {
                    target: title
                    property: "x"
                    to: 0
                }
            }
        }
    ]
}
