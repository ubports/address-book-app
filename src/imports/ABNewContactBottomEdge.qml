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
    // WORKAROUND: BottomEdge component loads the page async while draging it
    // this cause a very bad visual.
    // To avoid that we create it as soon as the component is ready and keep
    // it invisible until the user start to drag it.
    property var _realPage: null

    function editContact(contact)
    {
        _contactToEdit = contact
        commit()
    }

    hint {
        id: bottomEdgeHint
        action: Action {
            iconName: "contact-new"
            enabled: bottomEdge.enabled

            onTriggered: bottomEdge.commit()
        }
    }

    contentComponent: Item {
        id: pageContent

        implicitWidth: bottomEdge.width
        implicitHeight: bottomEdge.height
        children: bottomEdge._realPage
    }


    onCommitCompleted: {
        if (bottomEdge._contactToEdit)
            editorPage.contact = bottomEdge._contactToEdit
        bottomEdge._contactToEdit = null
    }

    onCollapseCompleted: {
        _realPage = editorPageBottomEdge.createObject(null)
    }

    Component.onCompleted:  {
        _realPage = editorPageBottomEdge.createObject(null)
    }

    Component {
        id: editorPageBottomEdge

        ABContactEditorPage {
            implicitWidth: bottomEdge.width
            implicitHeight: bottomEdge.height
            contact: ContactsUI.ContactsJS.createEmptyContact("", bottomEdge)
            model: bottomEdge.modelToEdit
            enabled: bottomEdge.status === BottomEdge.Committed
            active: bottomEdge.status === BottomEdge.Committed
            visible: bottomEdge.status !== BottomEdge.Hidden
            onCanceled: bottomEdge.collapse()
            onContactSaved: bottomEdge.collapse()
            pageStack: bottomEdge.pageStack
        }
    }
}
