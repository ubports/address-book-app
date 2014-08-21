/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.Components 1.1
import QtTest 1.0
import Ubuntu.Test 0.1
import Ubuntu.Contacts 0.1

Item {
    id: root

    property var itemList: null

    width: units.gu(40)
    height: units.gu(80)

    Component {
        id: itemListComponent

        Column {
            id: itemList

            readonly property int rightActionsLength: 3

            signal actionTriggered(var action)

            property var signalSpy: SignalSpy {
                target: itemList
                signalName: "actionTriggered"
            }

            anchors.fill: parent

            Repeater {
                model: 3

                ListItemWithActions {
                    id: listWithActions
                    objectName: "listWithActions" + index

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: units.gu(8)
                    triggerActionOnMouseRelease: true
                    Rectangle {
                        anchors.fill: parent
                        color: "green"
                    }

                    leftSideAction: Action {
                        id: deleteAction
                        objectName: "deleteAction"

                        iconName: "delete"
                        onTriggered: itemList.actionTriggered(deleteAction, value)
                    }

                    rightSideActions: [
                        Action {
                            id: messageAction

                            iconName: "message"
                            onTriggered: itemList.actionTriggered(messageAction)
                        },
                        Action {
                            id: shareAction

                            iconName: "share"
                            onTriggered: itemList.actionTriggered(shareAction)
                        },
                        Action {
                            id: contactAction

                            iconName: "stock_contact"
                            onTriggered: itemList.actionTriggered(contactAction)
                        }
                    ]
                }
            }

            Repeater {
                model: 3

                ListItemWithActions {
                    id: listWithNoRightActions
                    objectName: "listWithNoRightActions" + index

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: units.gu(8)
                    triggerActionOnMouseRelease: true
                    Rectangle {
                        anchors.fill: parent
                        color: "pink"
                    }

                    leftSideAction: Action {
                        objectName: "deleteAction2"

                        iconName: "delete"
                        onTriggered: itemList.actionTriggered(deleteAction, value)
                    }
                }
            }

            Repeater {
                model: 3

                ListItemWithActions {
                    id: listWithInvisibleActions
                    objectName: "listWithInvisibleActions"+ index

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: units.gu(8)
                    triggerActionOnMouseRelease: true
                    Rectangle {
                        anchors.fill: parent
                        color: "blue"
                    }

                    leftSideAction: Action {
                        objectName: "deleteAction2"

                        iconName: "delete"
                        onTriggered: itemList.actionTriggered(deleteAction, value)
                    }

                    rightSideActions: [
                        Action {
                            id: messageAction2

                            iconName: "message"
                            onTriggered: itemList.actionTriggered(messageAction2)
                        },
                        Action {
                            id: shareAction2

                            iconName: "share"
                            visible: false
                            onTriggered: itemList.actionTriggered(shareAction2)
                        },
                        Action {
                            id: contactAction2

                            iconName: "stock_contact"
                            onTriggered: itemList.actionTriggered(contactAction2)
                        },
                        Action {
                            id: infoAction2

                            iconName: "info"
                            visible: false
                            onTriggered: itemList.actionTriggered(shareAction2)
                        }
                    ]
                }
            }
        }
    }

    UbuntuTestCase {
        id: listWithActionsTestCase
        name: 'listWithActionsTestCase'

        when: windowShown

        function init()
        {
            itemList = itemListComponent.createObject(root)
        }

        function cleanup()
        {
            itemList.destroy()
        }

        function mouseMoveSlowly(item, x, y, dx, dy, steps, stepdelay) {
            mouseMove(item, x, y);
            var abs_dx = Math.abs(dx)
            var abs_dy = Math.abs(dy)
            var step_dx = dx / steps;
            var step_dy = dy /steps;

            var ix = 0;
            var iy = 0;

            for (var step=0; step < steps; step++) {
                if (ix < abs_dx) {
                    ix += step_dx;
                }
                if (iy < abs_dy) {
                    iy += step_dy;
                }
                mouseMove(item, x + ix, y + iy, stepdelay);
            }
        }


        function swipeToDeleteItem(itemName)
        {
            var item = findChild(itemList, itemName)
            var startX = item.threshold
            var startY = item.height / 2
            var endX = item.width
            var endY = startY
            mousePress(item, startX, startY)
            mouseMoveSlowly(item,
                            startX, startY,
                            endX - startX, endY - startY,
                            10, 100)
            mouseRelease(item, endX, endY)
            tryCompare(item, "swipeState", "LeftToRight")
            return item
        }

        function swipeToLeft(itemName, actionIndex, release)
        {
            var item = findChild(itemList, itemName)
            var startX = item.width - item.threshold
            var startY = item.height / 2
            var endX = 0
            var endY = startY

            if (actionIndex !== -1)
                endX = startX - ((actionIndex * (item.actionWidth + units.gu(2))) + item.actionThreshold + units.gu(1))
            else
                endX = 0

            mousePress(item, startX, startY)
            mouseMoveSlowly(item,
                            startX, startY,
                            endX - startX, endY - startY,
                            10, 100)
            if (release)
                mouseRelease(item, endX, endY)

            tryCompare(item, "swipeState", "RightToLeft")
            return item
        }

        function commom_data()
        {
            var data = []
            data.push({actionIndex: 1, iconName: "message"})
            data.push({actionIndex: 2, iconName: "share"})
            data.push({actionIndex: 3, iconName: "stock_contact"})
            return data
        }

        function test_cancelSwipeToDelete()
        {
            var item = swipeToDeleteItem("listWithActions2")
            mouseClick(item, item.width / 2, item.height / 2)
            compare(itemList.signalSpy.count, 0)
        }

        function test_swipeToDelete()
        {
            var item = swipeToDeleteItem("listWithActions2")
            mouseClick(item, item.actionThreshold, item.height / 2)
            itemList.signalSpy.wait()
            compare(itemList.signalSpy.count, 1)
            compare(itemList.signalSpy.signalArguments[0][0].iconName, "delete")
        }

        function test_activeRightActions_data()
        {
            return commom_data()
        }

        function test_activeRightActions(data)
        {
            var item = swipeToLeft("listWithActions2", data.actionIndex, false)
            compare(itemList.signalSpy.count, 0)
            compare(item.activeAction.iconName, data.iconName)
            mouseRelease(item, 0, 0)
            itemList.signalSpy.wait()
            compare(itemList.signalSpy.count, 1)
            compare(itemList.signalSpy.signalArguments[0][0].iconName, data.iconName)
        }

        function test_lockOnFullSwipe()
        {
            var item = swipeToLeft("listWithActions2", -1, true)
            compare(itemList.signalSpy.count, 0)
            tryCompare(item, "swipeState", "RightToLeft")
        }

        function test_fullSwipeAndClickOnAction_data()
        {
            return commom_data()
        }

        function test_fullSwipeAndClickOnAction(data)
        {
            var item = swipeToLeft("listWithActions2", -1, true)
            var actionOffset = (itemList.rightActionsLength - data.actionIndex) + 1
            var clickX = item.width - ((actionOffset * (item.actionWidth + units.gu(2))) + item.actionWidth / 2)
            mouseClick(item, clickX, item.height / 2)
            itemList.signalSpy.wait()
            compare(itemList.signalSpy.count, 1)
            compare(itemList.signalSpy.signalArguments[0][0].iconName, data.iconName)
        }

        function test_noSwipeWithEmptyRightActions()
        {
            var item = findChild(itemList, "listWithNoRightActions2")
            var startX = item.width - item.threshold
            var y = item.height / 2
            mousePress(item, startX, y)
            mouseMoveSlowly(item, startX, y, -startX, y, 10, 100)
            var mainItem = findChild(item, "mainItem")
            compare(mainItem.x, 0)
        }

        function test_not_visibleActions()
        {
            var item = swipeToLeft("listWithInvisibleActions2", -1, true)
            compare(item._visibleRightSideActions.length, 2)

            // check if only 2 actions is visible
            var mainItem = findChild(item, "mainItem")
            console.debug("SIZE: " + units.gu(1))
            tryCompare(mainItem, "x", (item.actionWidth * -2) - units.gu(5) - item.actionThreshold)
        }
    }
}
