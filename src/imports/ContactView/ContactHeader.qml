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
import Ubuntu.Components.ListItems 0.1 as ListItem

FocusScope {
    id: contactHeader

    property variant contact: null

    function edit() {
        for(var i = 0; i < contactHeader.children.length; ++i) {
            var field = contactHeader.children[i]
            if (field.edit) {
                field.edit()
            }
        }
    }

    function save() {
        for(var i = 0; i < contactHeader.children.length; ++i) {
            var field = contactHeader.children[i]
            if (field.save) {
                field.save()
            }
        }
    }

    function cancel() {
        for(var i = 0; i < contactHeader.children.length; ++i) {
            var field = contactHeader.children[i]
            if (field.cancel) {
                field.cancel()
            }
        }
    }

    implicitHeight: detailName.height + units.gu(2)

    ContactDetailAvatar {
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

    ContactDetailName {
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

    ContactDetailFavorite {
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
