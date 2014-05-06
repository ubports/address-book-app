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

import QtQuick 2.2
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

FocusScope {
    id: contactHeader

    property variant contact: null

    implicitHeight: units.gu(12)

    ContactDetailAvatarView {
        id: detailAvatar

        contact: contactHeader.contact
        anchors {
            top: parent.top
            topMargin: units.gu(2)
            left: parent.left
            leftMargin: units.gu(1)
        }
        width: units.gu(8)
        height: units.gu(8)
    }

    ContactDetailNameView {
        id: detailName

        contact: contactHeader.contact
        anchors {
            left: detailAvatar.right
            right: detailFavorite.right
            top: parent.top
            margins: units.gu(2)
        }
        height: implicitHeight
    }

    ContactDetailFavoriteView {
        id: detailFavorite

        contact: contactHeader.contact
        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }

        height: units.gu(2)
        width: units.gu(2)
    }

    ListItem.ThinDivider {
        id: bottomDividerLine
        anchors.bottom: parent.bottom
    }
}
