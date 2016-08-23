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
    property alias hintVisible: bottomEdgeHint.visible
    property var _contactToEdit: null

    function editContact(contact)
    {
        _contactToEdit = contact
        commit()
    }

    function close()
    {
        if (pageStack.bottomEdgeFloatingPage) {
            pageStack.removePages(pageStack.bottomEdgeFloatingPage)
        }
    }

    function pushPage()
    {
        var properties = {enabled: true,
                          visible: true,
                          parent: bottomEdge.parent}
        if (bottomEdge._contactToEdit)
            properties[contact] = bottomEdge._contactToEdit


        var incubator = pageStack.addPageToNextColumn(bottomEdge.parent, editorPageBottomEdge, properties)
        incubator.forceCompletion()
        pageStack.bottomEdgeFloatingPage = incubator.object
        incubator.object.Component.onDestruction.connect(function() {
            pageStack.bottomEdgeFloatingPage = null
        })
        bottomEdge._contactToEdit = null
    }

    hint {
        id: bottomEdgeHint
        action: Action {
            iconName: "contact-new"
            enabled: bottomEdge.enabled

            onTriggered: bottomEdge.commit()
        }
    }

    contentComponent: editorPageBottomEdge
    preloadContent: visible

    onCommitCompleted: {
        pushPage()
        collapse()
    }

    Component {
        id: editorPageBottomEdge

        ABContactEditorPage {
            id: editorPageItem

            implicitHeight: mainWindow.height
            implicitWidth: parent ? parent.width : bottomEdge.width
            enabled: false
            model: bottomEdge.modelToEdit
            contact: ContactsUI.ContactsJS.createEmptyContact("", editorPageItem)
            onCanceled: pageStack.removePages(editorPageItem)
            onContactSaved: pageStack.removePages(editorPageItem)
            pageStack: bottomEdge.pageStack
        }
    }
}
