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
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Rectangle {
    id: root

    signal reject()
    signal accept()

    property alias acceptAction: accept.action
    property alias rejectAction: reject.action

    color: "gray"

    Button {
        id: reject
        objectName: "DialogButtons.rejectButton"

        action: Action {
            text: i18n.dtr("address-book-app", "Cancel")
        }
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        color: UbuntuColors.warmGrey
        onClicked: root.reject()
    }

    Button {
        id: accept
        objectName: "DialogButtons.acceptButton"

        action: Action {
            text: i18n.dtr("address-book-app", "Done")
        }
        anchors {
            right: parent.right
            rightMargin: units.gu(1)
            verticalCenter: parent.verticalCenter
        }
        onClicked: root.accept()
    }
}
