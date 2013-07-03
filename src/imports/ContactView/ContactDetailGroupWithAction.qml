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
import QtContacts 5.0 as QtContacts

ContactDetailGroupBase {
    id: root

    property variant fields
    property string defaultIcon : "artwork:/protocol-other.png"
    property ListModel typeModel

    function getType(detail) {
        return typeModel.get(getTypeIndex(detail))
    }

    function getTypeIndex(detail) {
        var context = -1;
        for (var i = 0; i < detail.contexts.length; i++) {
            context = detail.contexts[i];
            break;
        }
        var subType = -1;
        // not all details have subTypes
        if (detail.subTypes) {
            for (var i = 0; i < detail.subTypes.length; i++) {
                subType = detail.subTypes[i];
                break;
            }
        }
        if (context === QtContacts.ContactDetail.ContextHome) {
            return 0
        } else if (context === QtContacts.ContactDetail.ContextWork) {
            return 1
        } else if (subType === QtContacts.ContactDetail.ContextOther) {
            return 2
        } else {
            return 2
        }
    }

    view: ContactDetailViewWithAction {
        property variant detailType: root.typeModel.count && detail ? root.getType(detail) : null

        subtitle.text: detailType ? detailType.label : ""
        actionIcon: detailType && detailType.icon ? detailType.icon : root.defaultIcon
        fields: root.fields

        height: implicitHeight
        anchors {
            left: parent ? parent.left : undefined
            right: parent ? parent.right : undefined
        }
    }

    editor: ContactDetailEditorWithAction {
        height: implicitHeight
        fields: root.fields
        selectedTypeIndex: detail ? root.getTypeIndex(detail) : -1
        types: {
            if (typeModel.count > 0) {
                var newTypes = [];
                for(var i=0; i < typeModel.count; i++) {
                    newTypes[i] = typeModel.get(i).label
                }
                return newTypes
            } else {
                return []
            }
        }

        anchors {
            left: parent ? parent.left : undefined
            right: parent ? parent.right : undefined
        }
        Rectangle {
            opacity: 0.3
            anchors.fill: parent
        }
    }

    typeModel: ListModel {
        Component.onCompleted: {
            append({"value": "Home", "label": i18n.tr("Home"), icon: null})
            append({"value": "Work", "label": i18n.tr("Work"), icon: null})
            append({"value": "Other", "label": i18n.tr("Other"), icon: null})
        }
    }
}
