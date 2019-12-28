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

import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    property Action leftSideAction: null
    property list<Action> rightSideActions
    property double defaultHeight: units.gu(8)
    property bool locked: false
    property Action activeAction: null
    property var activeItem: null
    property bool triggerActionOnMouseRelease: false
    property color color: Theme.palette.normal.background
    property color selectedColor: "#F7F7F7"
    property color selectedBorderColor: "transparent"
    property bool selected: false
    property bool selectionMode: false
    property alias internalAnchors: mainContents.anchors
    property alias animated: behaviorOnX.enabled
    default property alias contents: mainContents.children

    readonly property double actionWidth: units.gu(4)
    readonly property double leftActionWidth: units.gu(10)
    readonly property double actionThreshold: actionWidth * 0.4
    readonly property double threshold: 0.4
    readonly property string swipeState: main.x == 0 ? "Normal" : main.x > 0 ? "LeftToRight" : "RightToLeft"
    readonly property alias swipping: mainItemMoving.running
    readonly property bool _showActions: mouseArea.pressed || swipeState != "Normal" || swipping

    /* internal */
    property var _visibleRightSideActions: filterVisibleActions(rightSideActions)

    signal itemClicked(var mouse)
    signal itemPressAndHold(var mouse)

    function returnToBoundsRTL(direction)
    {
        var actionFullWidth = actionWidth + units.gu(2)

        // go back to normal state if swipping reverse
        if (direction === "LTR") {
            updatePosition(0)
            return
        } else if (!triggerActionOnMouseRelease) {
            updatePosition(-rightActionsView.width + units.gu(2))
            return
        }

        var xOffset = Math.abs(main.x)
        var index = Math.min(Math.floor(xOffset / actionFullWidth), _visibleRightSideActions.length)
        var newX = 0
      if (index === _visibleRightSideActions.length) {
            newX = -(rightActionsView.width - units.gu(2))
        } else if (index >= 1) {
            newX = -(actionFullWidth * index)
        }
        updatePosition(newX)
    }

    function returnToBoundsLTR(direction)
    {
        var finalX = leftActionWidth
        if ((direction === "RTL") || (main.x <= (finalX * root.threshold)))
            finalX = 0
        updatePosition(finalX)
    }

    function returnToBounds(direction)
    {
        if (main.x < 0) {
            returnToBoundsRTL(direction)
        } else if (main.x > 0) {
            returnToBoundsLTR(direction)
        } else {
            updatePosition(0)
        }
    }

    function contains(item, point, marginX)
    {
        var itemStartX = item.x - marginX
        var itemEndX = item.x + item.width + marginX
        return (point.x >= itemStartX) && (point.x <= itemEndX) &&
               (point.y >= item.y) && (point.y <= (item.y + item.height));
    }

    function getActionAt(point)
    {
        if (contains(leftActionView, point, 0)) {
            return leftSideAction
        } else if (contains(rightActionsView, point, 0)) {
            var newPoint = root.mapToItem(rightActionsView, point.x, point.y)
            for (var i = 0; i < rightActionsRepeater.count; i++) {
                var child = rightActionsRepeater.itemAt(i)
                if (contains(child, newPoint, units.gu(1))) {
                    return i
                }
            }
        }
        return -1
    }

    function updateActiveAction()
    {
        if (triggerActionOnMouseRelease &&
            (main.x <= -(root.actionWidth + units.gu(2))) &&
            (main.x > -(rightActionsView.width - units.gu(2)))) {
            var actionFullWidth = actionWidth + units.gu(2)
            var xOffset = Math.abs(main.x)
            var index = Math.min(Math.floor(xOffset / actionFullWidth), _visibleRightSideActions.length)
            index = index - 1
            if (index > -1) {
                root.activeItem = rightActionsRepeater.itemAt(index)
                root.activeAction = root._visibleRightSideActions[index]
            }
        } else {
            root.activeAction = null
        }
    }

    function resetSwipe()
    {
        updatePosition(0)
    }

    function filterVisibleActions(actions)
    {
        var visibleActions = []
        for(var i = 0; i < actions.length; i++) {
            var action = actions[i]
            if (action.visible) {
                visibleActions.push(action)
            }
        }
        return visibleActions
    }

    function updatePosition(pos)
    {
        if (!root.triggerActionOnMouseRelease && (pos !== 0)) {
            mouseArea.state = pos > 0 ? "RightToLeft" : "LeftToRight"
        } else {
            mouseArea.state = ""
        }
        main.x = pos
    }

    states: [
        State {
            name: "select"
            when: selectionMode
            PropertyChanges {
                target: selectionIcon
                source: Qt.resolvedUrl("ListItemWithActionsCheckBox.qml")
                anchors.leftMargin: units.gu(2)
            }
            PropertyChanges {
                target: root
                locked: true
            }
            PropertyChanges {
                target: main
                x: 0
            }
        }
    ]

    height: defaultHeight
    clip: height !== defaultHeight

    Rectangle {
        id: leftActionView

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: main.left
        }
        width: root.leftActionWidth + actionThreshold
        visible: leftSideAction
        color: UbuntuColors.red

        Icon {
            anchors {
                centerIn: parent
                horizontalCenterOffset: actionThreshold / 2
            }
            name: leftSideAction && _showActions ? leftSideAction.iconName : ""
            color: Theme.palette.selected.field
            height: units.gu(3)
            width: units.gu(3)
            asynchronous: true
        }
    }

    Rectangle {
       id: rightActionsView

       anchors {
           top: main.top
           left: main.right
           bottom: main.bottom
       }
       visible: _visibleRightSideActions.length > 0
       width: rightActionsRepeater.count > 0 ? rightActionsRepeater.count * (root.actionWidth + units.gu(2)) + root.actionThreshold + units.gu(2) : 0
       color: "white"
       Row {
           anchors{
               top: parent.top
               left: parent.left
               leftMargin: units.gu(2)
               right: parent.right
               rightMargin: units.gu(2)
               bottom: parent.bottom
           }
           spacing: units.gu(2)
           Repeater {
               id: rightActionsRepeater

               model: _showActions ? _visibleRightSideActions : []
               Item {
                   property alias image: img

                   height: rightActionsView.height
                   width: root.actionWidth

                   Icon {
                       id: img

                       anchors.centerIn: parent
                       width: units.gu(3)
                       height: units.gu(3)
                       name: modelData.iconName
                       color: root.activeAction === modelData ? UbuntuColors.orange : UbuntuColors.lightGrey
                       asynchronous: true
                   }
              }
           }
       }
    }

    Rectangle {
        id: main
        objectName: "mainItem"

        anchors {
            top: parent.top
            bottom: parent.bottom
        }

        width: parent.width
        border {
            color: root.selectedBorderColor
            width: root.selected ? units.dp(1) : 0
        }
        color: root.selected ? root.selectedColor : root.color

        Loader {
            id: selectionIcon
            objectName: "selectionIcon"

            anchors {
                left: main.left
                verticalCenter: main.verticalCenter
            }
            width: (status === Loader.Ready) ? item.implicitWidth : 0
            visible: (status === Loader.Ready) && (item.width === item.implicitWidth)
            Behavior on width {
                NumberAnimation {
                    duration: UbuntuAnimation.SnapDuration
                }
            }
        }

        Item {
            id: mainContents

            anchors {
                left: selectionIcon.right
                leftMargin: units.gu(2)
                top: parent.top
                topMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(2)
                bottom: parent.bottom
                bottomMargin: units.gu(1)
            }
        }

        Behavior on x {
            id: behaviorOnX

            UbuntuNumberAnimation {
                id: mainItemMoving

                easing.type: Easing.OutElastic
                duration: UbuntuAnimation.SlowDuration
            }
        }
        Behavior on color {
           ColorAnimation {}
        }
    }

    SequentialAnimation {
        id: clickAnimation

        running: false
        alwaysRunToEnd: true
        PropertyAnimation {
            target: main
            property: "color"
            to: root.selectedColor
        }
        PropertyAction {
            target: main
            property: "color"
            value: root.selected ? root.selectedColor : root.color
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
        ScriptAction {
            script: {
                root.activeAction.triggered(root)
                mouseArea.state = ""
            }
        }
        PauseAnimation {
            duration: 500
        }
        UbuntuNumberAnimation {
            target: main
            property: "x"
            to: 0

        }
    }

    MouseArea {
        id: mouseArea

        property bool locked: root.locked || ((root.leftSideAction === null) && (root._visibleRightSideActions.count === 0))
        property bool manual: false
        property string direction: "None"
        property real lastX: -1

        anchors.fill: parent
        z: -1
        drag {
            target: locked ? null : main
            axis: Drag.XAxis
            minimumX: rightActionsView.visible ? -(rightActionsView.width) : 0
            maximumX: leftActionView.visible ? leftActionView.width : 0
            threshold: root.actionThreshold
        }

        states: [
            State {
                name: "LeftToRight"
                PropertyChanges {
                    target: mouseArea
                    drag.maximumX: 0
                }
            },
            State {
                name: "RightToLeft"
                PropertyChanges {
                    target: mouseArea
                    drag.minimumX: 0
                }
            }
        ]

        onMouseXChanged: {
            var offset = (lastX - mouseX)
            if (Math.abs(offset) <= root.actionThreshold) {
                return
            }
            lastX = mouseX
            direction = offset > 0 ? "RTL" : "LTR";
        }

        onPressed: {
            lastX = mouse.x
        }

        onReleased: {
            if (root.triggerActionOnMouseRelease && root.activeAction) {
                triggerAction.start()
            } else {
                root.returnToBounds(direction)
                root.activeAction = null
            }
            lastX = -1
            direction = "None"
        }
        onClicked: {
            if (main.x === 0) {
                root.itemClicked(mouse)
                if (!root.selected)
                    clickAnimation.start()
            } else if (main.x > 0) {
                var action = getActionAt(Qt.point(mouse.x, mouse.y))
                if (action && action !== -1) {
                    action.triggered(root)
                }
            } else {
                var actionIndex = getActionAt(Qt.point(mouse.x, mouse.y))
                if (actionIndex !== -1) {
                    root.activeItem = rightActionsRepeater.itemAt(actionIndex)
                    root.activeAction = root._visibleRightSideActions[actionIndex]
                    triggerAction.start()
                    return
                }
            }
            root.resetSwipe()
        }

        onPositionChanged: {
            if (mouseArea.pressed) {
                updateActiveAction()
            }
        }
        onPressAndHold: {
            if (main.x === 0) {
                root.itemPressAndHold(mouse)
            }
        }
    }
}
