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

/*!
An "organic" list of photos.  Used as the "tray" contents for each event in
the OrganicEventView, and the layout of the OrganicAlbumView.
*/
Item {
    id: organicList

    readonly property alias count: listView.count
    property alias model: listView.model
    property Component delegate
    property Component header

    /// Size of the bigger thumbnails
    property var bigSize: units.gu(19)
    /// Size of the smaller thumbnails
    property var smallSize: units.gu(12)
    /// Space between the thumbnails
    property alias margin: listView.spacing

    QtObject {
        id: priv

        // readonly
        readonly property int mediaPerPattern: 6

        // internal, used to get the organix effect
        /// X-position shift for the delegates in one of the organic blocks
        readonly  property var photoX: [-margin, 0, 0, 0, 0, 0]
        /// Y-position shift for the delegates in one of the organic blocks
        readonly property var photoY: [smallSize + margin, 0, bigSize + margin, 0, bigSize + margin, 0]
        /// Size of the delegate in one of the organic blocks
        readonly property var photoSize: [bigSize, smallSize, smallSize, bigSize, smallSize, smallSize]
        /// Size to be adapted for the organic effect
        readonly property var photoWidth: [smallSize - margin, bigSize - (smallSize + margin), 2 * smallSize - bigSize, bigSize - (smallSize + margin), smallSize, 0]
        /// Extra space on the right, for correct scroll boundary
        readonly property var footerWidth: [smallSize,
                                            bigSize - smallSize,
                                            2 * smallSize - bigSize + margin,
                                            bigSize - smallSize,
                                            smallSize + margin,
                                            0]
        /// Used to generate a spacing between the events
        readonly property real photosTopMargin: margin / 2
    }

    implicitHeight: bigSize + smallSize + priv.photosTopMargin + margin + margin/2
    height: implicitHeight

    ListView {
        id: listView
        objectName: "displaced"
        // the buffers are needed, as the listview does not draw items outside is visible area
        // but for the organic effect, x and width are "displaced" for some items (first, last)
        property int leftBuffer: organicList.smallSize + organicList.margin
        property int rightBuffer: organicList.smallSize

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: -leftBuffer
            right: parent.right
            rightMargin: -rightBuffer
        }

        maximumFlickVelocity: units.gu(300)
        flickDeceleration: maximumFlickVelocity / 3
        cacheBuffer: 0
        orientation: Qt.Horizontal
        spacing: units.gu(2)

        property int ccoun: children.length

        delegate: Item {
            id: itemDelegate

            property int patternPhoto: index % priv.mediaPerPattern

            width: priv.photoWidth[patternPhoto]
            height: priv.photoSize[patternPhoto]

            Loader {
                id: delegateLoader

                property var model: null
                property int index: -1

                x: priv.photoX[patternPhoto]
                y: priv.photosTopMargin + priv.photoY[patternPhoto]

                width: parent.height
                height: parent.height
                sourceComponent: organicList.delegate
            }

            Binding {
                target: delegateLoader
                property: "model"
                value: model
            }

            Binding {
                target: delegateLoader
                property: "index"
                value: index
            }
        }

        header: Loader {
            width: listView.leftBuffer + 2 * organicList.margin
            height: organicList.smallSize

            sourceComponent: organicList.header
        }

        footer: Item {
            width: listView.rightBuffer + priv.footerWidth[listView.count % priv.mediaPerPattern] + listView.spacing
        }
    }
}
