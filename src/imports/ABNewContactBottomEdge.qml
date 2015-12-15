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
    property var _contactToEdit: null
    // WORKARDOUND: Bottom edge element overriwrite the page leading actions and
    // we can not handle the 'back' button in the app.
    // Because of that we use '_signalFired' to know if any signal was fired
    // before start to close the page. If I signal was fired we continue the operation
    // if no signal was fired this mean that the 'collapse' button was clicked and we
    // need to fire the 'cancel' signal
    property bool _signalFired: false

    function editContact(contact)
    {
        _contactToEdit = contact
        commit()
    }

    hint {
        action: Action {
            iconName: "contact-new"
            shortcut: bottomEdge.status !== BottomEdge.Committed ? "ctrl+n" : "esc"
            enabled: bottomEdge.enabled

            onTriggered: {
                if (bottomEdge.status === BottomEdge.Committed)
                    bottomEdge.collapse()
                else
                    bottomEdge.commit()
            }
        }
    }
    contentComponent: editorPageBottomEdge
    onCollapseStarted: {
        if (!_signalFired) {
            _signalFired = true
            if (contentItem)
                contentItem.cancel()
        }
    }

    onCommitCompleted: {
        _signalFired = false
        if (bottomEdge._contactToEdit)
            editorPage.contact = bottomEdge._contactToEdit
        bottomEdge._contactToEdit = null
        contentItem.enabled = true
    }

    Component {
        id: editorPageBottomEdge

        ABContactEditorPage {
            implicitWidth: mainPage.width
            implicitHeight: bottomEdge.height
            title: i18n.tr("New Contact")
            contact: ContactsUI.ContactsJS.createEmptyContact("", bottomEdge)
            model: bottomEdge.modelToEdit
            initialFocusSection: "name"
            enabled: bottomEdge.status === BottomEdge.Committed
            visible: bottomEdge.status !== BottomEdge.Hidden
            onCanceled: {
                _signalFired = true
                bottomEdge.collapse()
            }
            onContactSaved: {
                _signalFired = true
                bottomEdge.collapse()
            }
        }
    }
}
