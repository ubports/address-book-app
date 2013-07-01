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
import QtContacts 5.0

ContactDetailItem {
    id: root

    detail: contact ? contact.avatar : null
    view: UbuntuShape {
        anchors.fill: parent
        image: Image {
            source: root.detail && root.detail.imageUrl != "" ? root.detail.imageUrl : "artwork:/avatar-default.png"
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            // since we don't know if the image is portrait or landscape without actually reading it,
            // set the sourceSize to be the size we need plus 30% to allow cropping.
            sourceSize.width: width * 1.3
            sourceSize.height: height * 1.3
        }
   }
}
