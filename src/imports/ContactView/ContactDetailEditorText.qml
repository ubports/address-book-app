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

ContactDetailEditor {
    id: detailEditor

    property bool removable: true

    function save() {
        for(var i = 0; i < contents.children.length; ++i) {
            var input = contents.children[i]
            //input.updateDetail()
        }
    }

    implicitHeight: contents.childrenRect.height + units.gu(1)

    Column {
        id: contents

        spacing: units.gu(0.5)
        anchors.fill: parent

        Repeater {
            id: repeater

            model: enabled ? fields : 0
            TextInputDetail {
                detail: detailEditor.detail
                field: modelData
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(4)
            }
        }
    }
}
