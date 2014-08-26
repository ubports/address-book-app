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

Column {
    id: root

    property alias parentView: scrollAnimation.target
    property alias header: listHeader.children
    readonly property alias count: callerRepeat.count

    /* internal */
    property int _nextCurrentIndex: -1


    function makeItemVisible(item)
    {
        if (!item) {
            return
        }

        var itemY = root.y + item.y
        var areaY = parentView.contentY
        if (itemY < areaY) {
            // move foward
            scrollAnimation.to = itemY
        } else if ((areaY + parentView.height) < (itemY + item.height)) {
            // move backward
            scrollAnimation.to = itemY + item.height
        } else {
            return
        }
        scrollAnimation.restart()
    }

    height: visible && (callerRepeat.count > 0) ? childrenRect.height : 0

    SmoothedAnimation {
        id: scrollAnimation

        property: "contentY"
        velocity: parentView.highlightMoveVelocity
        duration: parentView.highlightMoveDuration
    }

    Item {
        id: listHeader
        anchors {
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height
    }

    SectionDelegate {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
        text: i18n.dtr("address-book-app", "Frequently called")
    }

    Repeater {
        id: callerRepeat

        model: MostCalledModel {
            id: calledModel

            onInfoRequested: parentView.infoRequested(contact)
            onDetailClicked: parentView.detailClicked(contact, detail, action)
            onAddDetailClicked: parentView.addDetailClicked(contact, detailType)
            onAddContactClicked: parentView.addContactClicked(label)
            onCurrentIndexChanged: {
                if (currentIndex !== -1) {
                    parentView.currentIndex = -1
                    root._nextCurrentIndex = currentIndex
                }
            }

            // WORKAROUND: The SDK header causes the contactY to move to a wrong postion
            // calling the positionViewAtBeginning after the list created fix that
            onLoaded: moveToBegining.restart()
        }
    }

    Connections {
        target: parentView
        onCurrentIndexChanged: {
            if (parentView.currentIndex !== -1) {
                calledModel.currentIndex = -1
            }
        }
    }

    onHeightChanged: {
        if (root._nextCurrentIndex != -1) {
            heightChangedTimeout.restart()
        }
    }

    Timer {
        id: heightChangedTimeout
        interval: 100
        onTriggered: {
            makeItemVisible(callerRepeat.itemAt(root._nextCurrentIndex))
            root._nextCurrentIndex = -1
        }
    }

    onVisibleChanged: {
        // update the model every time that it became visible
        // in fact calling update only reloads the model data if it has changed
        if (visible) {
            calledModel.model.update()
        }
    }
}
