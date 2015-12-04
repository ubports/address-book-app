/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
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
import Ubuntu.Contacts 0.1 as ContactsUI

BottomEdge {
    id: bottomEdge
    objectName: "bottomEdge"

    property var pageStack: null
    property var _contactToEdit: null
    property var _modelToEdit: null

    function editContact(contact, model)
    {
        _contactToEdit = contact
        _modelToEdit = model
        commit()
    }

    hint {
        action: Action {
            iconName: "contact-new"
            onTriggered: bottomEdge.commit()
            shortcut: "ctrl+n"
            enabled: bottomEdge.enabled
        }
    }
    contentComponent: editorPageBottomEdge
    onCommitCompleted: {
        var editorPage = bottomEdge.contentItem
        bottomEdge.pageStack.addPageToCurrentColumn(bottomEdge.parent, bottomEdge.contentItem)
        editorPage.contact = bottomEdge._contactToEdit
        editorPage.model = bottomEdge._modelToEdit
        bottomEdge._contactToEdit = null
        bottomEdge._modelToEdit = null
    }

    Component {
        id: editorPageBottomEdge

        ABContactEditorPage {
            implicitWidth: mainPage.width
            implicitHeight: bottomEdge.height
            contact: ContactsUI.ContactsJS.createEmptyContact("", bottomEdge)
            initialFocusSection: "name"
            enabled: false
            visible: bottomEdge.satus != BottomEdge.Hidden
            onCanceled: bottomEdge.collapse()
        }
    }
}
