/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
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


Page {
    id: root

    property string headerTitle: i18n.tr("No contacts")

    property bool openBottomEdgeWhenReady: false
    property var model: null

    header: PageHeader {
        title: root.headerTitle
    }

    function commitBottomEdge()
    {
        if (bottomEdgeLoader.status !== Loader.Ready) {
            openBottomEdgeWhenReady = true
        } else {
            bottomEdgeLoader.item.commit()
        }
    }

    function close()
    {
        if (bottomEdge.item) {
            bottomEdge.item.close()
        }
    }


    ABEmptyState {
        id: emptyStateScreen

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: units.gu(6)
            rightMargin: units.gu(6)
        }
        height: childrenRect.height
        text: ""
    }

    Loader {
        id: bottomEdgeLoader

        asynchronous: true
        Component.onCompleted: setSource(Qt.resolvedUrl("ABNewContactBottomEdge.qml"),
                                         {"hintVisible": false,
                                          "visible": Qt.binding(function () {return mainPage.pageStack.columns > 1}),
                                          "parent": root,
                                          "height": Qt.binding(function () {return root.height}),
                                          "modelToEdit": Qt.binding(function () {return root.model}),
                                          "hint.flickable": Qt.binding(function () {return root.flickable}),
                                          "pageStack": Qt.binding(function () {return root.pageStack})
                                         })

        Connections {
            target: bottomEdgeLoader.item
            onCommitCompleted: { root.openBottomEdgeWhenReady = false }
        }

        onStatusChanged:  {
            if ((status === Loader.Ready) && root.openBottomEdgeWhenReady) {
                bottomEdgeLoader.item.commit()
            }
        }

    }

    Binding {
        target: pageStack
        property: '_bottomEdge'
        value: bottomEdgeLoader.item
        when: (bottomEdgeLoader.status === Loader.Ready) && (pageStack.columns > 1)
    }


    // Remove empty page when app changes to 1 column mode
    Connections {
        target: pageStack
        onBottomEdgeOpenedChanged: {
            if (!pageStack.bottomEdgeOpened && (pageStack.columns === 1)) {
                pageStack.removePages(root)
            }
        }
    }
    onActiveChanged: {
        if (active && (pageStack.columns === 1)) {
            pageStack.removePages(root)
        }

    }
}
