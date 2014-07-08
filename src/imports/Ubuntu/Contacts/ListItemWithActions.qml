/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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

import QtQuick 2.2
import Ubuntu.Components 0.1

Item {
    id: root

    property Action leftSideAction: null
    property list<Action> rightSideActions
    property double defaultHeight: units.gu(8)
    property bool locked: false
    property Action activeAction: null
    property var activeItem: null
    property bool triggerActionOnMouseRelease: false
    property alias color: main.color
    default property alias contents: main.children

    readonly property double actionWidth: units.gu(5)
    readonly property double threshold: 0.4
    readonly property string swipeState: main.x == 0 ? "Normal" : main.x > 0 ? "LeftToRight" : "RightToLeft"
    readonly property alias swipping: mainItemMoving.running

    signal itemClicked(var mouse)
    signal itemPressAndHold(var mouse)

    function returnToBoundsRTL()
    {
        var xOffset = Math.abs(main.x)
        var actionFullWidth = actionWidth + units.gu(1)

        if (xOffset < actionFullWidth) {
            main.x = 0
        } else if (xOffset > (actionFullWidth * rightActionsRepeater.count)) {
            main.x = - (actionFullWidth * rightActionsRepeater.count)
        } else {
            for (var i = rightActionsRepeater.count; i >= 2; i--) {
                if (xOffset >= (actionFullWidth * i)) {
                    main.x = -(actionWidth * i)
                    return
                }
            }
            main.x = -actionWidth
        }
    }

    function returnToBoundsLTR()
    {
        var finalX = leftActionView.width
        if (main.x > (finalX * root.threshold))
            main.x = finalX
        else
            main.x = 0
    }

    function returnToBounds()
    {
        if (main.x < 0) {
            returnToBoundsRTL()
        } else if (main.x > 0) {
            returnToBoundsLTR()
        }
    }

    function contains(item, point)
    {
        return (point.x >= item.x) && (point.x <= (item.x + item.width)) && (point.y >= item.y) && (point.y <= (item.y + item.height));
    }

    function getActionAt(point)
    {
        if (contains(leftActionView, point)) {
            return leftSideAction
        } else if (contains(rightActionsView, point)) {
            var newPoint = root.mapToItem(rightActionsView, point.x, point.y)
            for (var i = 0; i < rightActionsRepeater.count; i++) {
                var child = rightActionsRepeater.itemAt(i)
                if (contains(child, newPoint)) {
                    return rightSideActions[i]
                }
            }
        }
        return null
    }

    function updateActiveAction()
    {
        var xOffset = Math.abs(main.x)
        if (main.x < 0) {
            for (var i = rightActionsRepeater.count - 1; i >= 0; i--) {
                var child = rightActionsRepeater.itemAt(i)
                var childOffset = rightActionsView.width - child.x
                if (xOffset <= childOffset) {
                    root.activeItem = child
                    root.activeAction = root.rightSideActions[i]
                    return
                }
            }
        } else {
            root.activeAction = null
        }
    }

    function resetSwipe()
    {
        main.x = 0
    }

    height: defaultHeight
    clip: height !== defaultHeight

    Rectangle {
        id: leftActionView

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: height
        visible: leftSideAction
        color: "red"

        Icon {
            anchors.centerIn: parent
            name: leftSideAction ? leftSideAction.iconName : ""
            color: Theme.palette.selected.field
            height: units.gu(3)
            width: units.gu(3)
        }
    }

    Item {
       id: rightActionsView

       anchors {
           top: main.top
           right: parent.right
           bottom: main.bottom
       }
       width: rightActionsRepeater.count * (root.actionWidth + units.gu(1))
       Row {
           anchors.fill: parent
           spacing: units.gu(1)
           Repeater {
               id: rightActionsRepeater

               model: rightSideActions
               Item {
                   property alias image: img

                   anchors {
                       top: parent.top
                       bottom: parent.bottom
                   }
                   width: root.actionWidth

                   Icon {
                       id: img

                       anchors.centerIn: parent
                       width: units.gu(3)
                       height: units.gu(3)
                       name: iconName
                       color: root.activeAction === modelData || !root.triggerActionOnMouseRelease ? UbuntuColors.lightAubergine : Theme.palette.selected.background
                   }
               }
           }
       }
    }


    Rectangle {
        id: main

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        width: parent.width
        Behavior on x {
            UbuntuNumberAnimation {
                id: mainItemMoving

                easing.type: Easing.OutElastic
                duration: UbuntuAnimation.SlowDuration
            }
        }
    }

    SequentialAnimation {
        id: triggerAction

        property var currentItem: root.activeItem ? root.activeItem.image : null

        running: false
        ParallelAnimation {
            UbuntuNumberAnimation {
                target: triggerAction.currentItem
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: UbuntuAnimation.SlowDuration
                easing {type: Easing.InOutBack; }
            }
            UbuntuNumberAnimation {
                target: triggerAction.currentItem
                properties: "width, height"
                from: units.gu(3)
                to: root.actionWidth
                duration: UbuntuAnimation.SlowDuration
                easing {type: Easing.InOutBack; }
            }
        }
        ScriptAction {
            script: {
                root.activeAction.triggered(root)
            }
        }
        PropertyAction {
            target: triggerAction.currentItem
            properties: "width, height"
            value: units.gu(3)
        }
        PropertyAction {
            target: triggerAction.currentItem
            properties: "opacity"
            value: 1.0
        }
        UbuntuNumberAnimation {
            target: main
            property: "x"
            to: 0
            easing.type: Easing.OutElastic
            duration: UbuntuAnimation.SlowDuration
        }
    }

    MouseArea {
        id: mouseArea

        property bool locked: root.locked || ((root.leftSideAction === null) && (root.rightSideActions.count === 0))

        anchors.fill: parent
        drag {
            target: locked ? null : main
            axis: Drag.XAxis
            minimumX: -rightActionsView.width
            maximumX: leftActionView.visible ? leftActionView.width : 0
        }

        onReleased: {
            if (root.triggerActionOnMouseRelease && root.activeAction) {
                triggerAction.start()
            } else {
                root.returnToBounds()
            }
        }
        onClicked: {
            if (main.x === 0) {
                root.itemClicked(mouse)
                return
            }

            var action = getActionAt(Qt.point(mouse.x, mouse.y))
            if (action) {
                action.triggered(root)
            }
            root.resetSwipe()
        }

        onPositionChanged: updateActiveAction()
        onPressAndHold: {
            if (main.x === 0) {
                root.itemPressAndHold(mouse)
            }
        }
        z: -1
    }
}
