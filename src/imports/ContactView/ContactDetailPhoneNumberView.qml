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
import Ubuntu.Components.ListItems 0.1 as ListItem

import "../Common"

ContactDetailBase {
    id: root

    property alias typeLabel: view.typeLabel
    property alias lineHeight: view.lineHeight

    function populateValues()
    {
        if (fields && detail) {
            var values = []
            for(var i=0; i < fields.length; i++) {
                values.push(detail.value(fields[i]))
            }
            view.values = values
        }
    }

    onFieldsChanged: populateValues()
    onDetailChanged: populateValues()

    BasicFieldView {
        id: view

        anchors {
            right: parent.right
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: units.gu(1)
        }
        iconSource: root.action ? root.action.iconSource : ""
    }
}
