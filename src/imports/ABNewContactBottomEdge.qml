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

    property var modelToEdit: null
    property var pageStack: null
    property var _contactToEdit: null

   function editContact(contact)
    {
        _contactToEdit = contact
        commit()
    }

    hint {
        action: Action {
            iconName: "contact-new"
            shortcut: "ctrl+n"
            enabled: bottomEdge.enabled

            onTriggered: bottomEdge.commit()
        }
    }
    contentComponent: editorPageBottomEdge

    onCommitCompleted: {
        if (bottomEdge._contactToEdit)
            editorPage.contact = bottomEdge._contactToEdit
        bottomEdge._contactToEdit = null
    }

    Component {
        id: editorPageBottomEdge

        ABContactEditorPage {
            implicitWidth: bottomEdge.width
            implicitHeight: bottomEdge.height
            title: i18n.tr("New Contact")
            contact: ContactsUI.ContactsJS.createEmptyContact("", bottomEdge)
            model: bottomEdge.modelToEdit
            initialFocusSection: "name"
            enabled: bottomEdge.status === BottomEdge.Committed
            active: bottomEdge.status === BottomEdge.Committed
            visible: contentItem
            onCanceled: bottomEdge.collapse()
            onContactSaved: bottomEdge.collapse()
            pageStack: bottomEdge.pageStack
        }
    }
}
