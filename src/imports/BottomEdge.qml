/*
 * Copyright (C) 2015 Canonical, Ltd.
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
    id: bottomEdge

    readonly property alias content: bottomEdgeLoader.item
    readonly property bool fullLoaded: bottomEdgeLoader.status == Loader.Ready

    property bool opened: false
    property Component contentComponent
    property string iconName
    property Item flickable
    property alias backGroundEffectEnabled: darkBg.visible

    signal openBegin
    signal openEnd
    signal clicked

    function open() {
        bottomEdge.state = "expanded";
    }

    function close() {
        bottomEdge.state = "collapsed";
    }

    Action {
        text: i18n.tr("New contact")
        enabled: bottomEdge.visible
        shortcut: "Ctrl+N"
        onTriggered: bottomEdge.clicked()
    }

    Rectangle {
        id: darkBg

        anchors.fill: parent
        color: "black"
        opacity: 0.0
    }

    Item {
        id: bottomEdgeBody
        anchors {
            left: parent.left
            right: parent.right
        }
        height: bottomEdgeContent.height

        Item {
            id: bottomEdgeContent
            anchors {
                left: parent.left
                right: parent.right
            }
            height: bottomEdgeLoader.height

            Item {
                id: bottomEdgeShadows
                anchors.fill: bottomEdgeContent

                BottomEdgeShadow {
                    anchors.bottom: parent.top
                }

                BottomEdgeShadow {
                    anchors.top: parent.bottom
                    rotation: 180
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.palette.normal.background
            }

            Loader {
                id: bottomEdgeLoader
                sourceComponent: bottomEdge.contentComponent
                asynchronous: true
                active: bottomEdge.enabled
            }
        }

        BottomEdgeHint {
            id: bottomEdgeHint

            anchors.bottom: bottomEdgeBody.top
            iconName: bottomEdge.iconName
            onClicked: bottomEdge.clicked()

            Connections {
                target: bottomEdgeDragArea
                onClosedChanged: {
                    if (!bottomEdgeDragArea.closed) {
                        bottomEdgeHint.state = "Visible";
                    }
                }
            }

            Connections {
                target: flickable
                onVerticalVelocityChanged: {
                    if (!bottomEdgeDragArea.closed) {
                        return;
                    }

                    if (flickable.verticalVelocity > 0) {
                        bottomEdgeHint.state = "Hidden";
                    } else if (flickable.verticalVelocity < 0) {
                        bottomEdgeHint.state = "Visible";
                    }
                }
            }
        }
    }


    state: "collapsed"
    states: [
        State {
            name: "collapsed"
            ParentChange {
                target: bottomEdgeContent
                parent: bottomEdgeBody
                x: 0
                y: 0
            }
            PropertyChanges {
                target: bottomEdgeBody
                y: bottomEdgeDragArea.drag.maximumY
            }
            PropertyChanges {
                target: bottomEdgeContent
                opacity: 0.0
            }
            PropertyChanges {
                target: darkBg
                opacity: 0.0
            }
        },
        State {
            name: "expanded"
            ParentChange {
                target: bottomEdgeContent
                parent: bottomEdge
                x: 0
                y: 0
            }
            PropertyChanges {
                target: bottomEdgeContent
                opacity: 1.0
            }
            PropertyChanges {
                target: bottomEdgeBody
                y: 0
            }
            PropertyChanges {
                target: bottomEdgeShadows
                opacity: 0.0
                visible: true
            }
            PropertyChanges {
                target: darkBg
                opacity: 0.8
            }
        },
        State {
            name: "floating"
            when: bottomEdgeDragArea.drag.active
            PropertyChanges {
                target: bottomEdgeContent
                opacity: 1.0
            }
            PropertyChanges {
                target: darkBg
                opacity: bottomEdgeBody.y > 0 ? 0.8 - (bottomEdgeBody.y / bottomEdgeDragArea.drag.maximumY) : 0.8
            }
        }
    ]

    transitions: [
        Transition {
            to: "collapsed"
            SequentialAnimation {
                alwaysRunToEnd: true
                ParallelAnimation {
                    ParentAnimation {
                        UbuntuNumberAnimation {
                            properties: "x,y"
                            duration: UbuntuAnimation.SlowDuration
                            target: bottomEdgeContent
                        }
                    }
                    UbuntuNumberAnimation {
                        target: bottomEdgeBody
                        property: "y"
                        duration: UbuntuAnimation.SlowDuration
                    }
                    UbuntuNumberAnimation {
                        target: darkBg
                        property: "opacity"
                        duration: UbuntuAnimation.SlowDuration
                    }
                }
                PropertyAction {
                    target: bottomEdgeContent
                    property: "opacity"
                }
                ScriptAction {
                    script: {
                        bottomEdgeLoader.active = false
                        bottomEdgeLoader.active = true
                        bottomEdge.opened = false
                    }
                }
            }
        },
        Transition {
            to: "expanded"
            SequentialAnimation {
                alwaysRunToEnd: true
                ParallelAnimation {
                    ScriptAction {
                        script: bottomEdge.openBegin()
                    }
                    ParentAnimation {
                        UbuntuNumberAnimation {
                            properties: "x,y"
                            duration: UbuntuAnimation.SlowDuration
                            target: bottomEdgeContent
                        }
                    }
                    UbuntuNumberAnimation {
                        target: bottomEdgeShadows
                        property: "opacity"
                        duration: UbuntuAnimation.SlowDuration
                    }
                    UbuntuNumberAnimation {
                        target: darkBg
                        property: "opacity"
                        duration: UbuntuAnimation.SlowDuration
                    }
                }
                UbuntuNumberAnimation {
                    target: bottomEdgeContent
                    property: "opacity"
                    duration: UbuntuAnimation.FastDuration
                }
                ScriptAction {
                    script: {
                        bottomEdge.opened = true
                        bottomEdge.openEnd()
                    }

                }
            }
        }
    ]

    MouseArea {
        id: bottomEdgeDragArea
        objectName: "bottomEdgeDragArea"

        property real previousY: -1
        property string dragDirection: "None"
        property bool closed: drag.target.y == bottomEdgeDragArea.drag.maximumY
                            && !bottomEdgeDragArea.pressed

        preventStealing: true
        propagateComposedEvents: true
        drag {
            axis: Drag.YAxis
            target: bottomEdgeBody
            minimumY: 0
            maximumY: bottomEdge.height
        }

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: bottomEdgeHint.height

        onPressed: {
            previousY = mouse.y;
        }

        onReleased: {
            if (dragDirection === "BottomToTop") {
                bottomEdge.state = "expanded";
            } else {
                bottomEdge.state = "collapsed";
            }
            previousY = -1;
            dragDirection = "None";
        }

        onMouseYChanged: {
            var yOffset = previousY - mouseY;
            // skip if was a small move
            if (Math.abs(yOffset) <= units.gu(2)) {
                return;
            }
            previousY = mouseY;
            dragDirection = yOffset > 0 ? "BottomToTop" : "TopToBottom";
        }
    }

    Binding {
        target: bottomEdge
        property: 'visible'
        value: bottomEdge.enabled && !bottomEdge.opened
    }
}
