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
    id: root

    property QtObject contact: null
    property list<QtObject> details
    property bool editable: false
    property bool valid: false
    property alias title: header.text

    property Component view
    property Component editor

    implicitHeight: root.details.length > 0 ? contents.childrenRect.height + units.gu(1) : 0
    visible: implicitHeight > 0

    function edit() {
        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.edit) {
                field.edit()
            }
        }
    }

    function save() {
        for(var i = 0; i < detailFields.children.length; ++i) {
            var field = detailFields.children[i]
            if (field.save) {
                field.save()
            }
        }
    }

    Column {
        id: contents

        anchors {
            left: parent.left
            right: parent.right
        }

        Label {
            id: header
            height: units.gu(3)
        }

        Repeater {
            id: detailFields

            model: root.details.length
            ContactDetailItem {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
                contact: root.contact
                detail: root.details[index]
                editable: root.editable
                valid: root.valid
                view: root.view
                editor: root.editor
            }
        }
    }
}
