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
import Ubuntu.Components.Popups 1.3 as Popups
import Ubuntu.Contacts 0.1

import Ubuntu.AddressBook.Base 0.1
import Ubuntu.AddressBook.ContactView 0.1

ContactViewPage {
    id: root
    objectName: "contactViewPage"

    // used by autopilot test
    readonly property string headerTitle: header.title
    readonly property bool editing: _editPage != null

    // FIXME: bug #1544745
    // Adaptive layout is not destroying all pages correct, we do it manually for now
    property var _editPage: null
    function cancelEdit()
    {
        if (_editPage) {
            pageStack.removePages(_editPage)
            _editPage = null
        }
        if (pageStack.bottomEdge) {
            pageStack.bottomEdge.close()
        }
    }

    function editContact(contact)
    {
        root._editPage = pageStack.addComponentToCurrentColumnSync(root, Qt.resolvedUrl("ABContactEditorPage.qml"),
                                                                  { model: root.model, contact: contact, backIconName: 'back'})
        root._editPage.Component.onDestruction(function() {
            root._editPage = null
        })
    }

    // Shortcut in case of single column
    Action {
        id: backAction

        name: "cancel"
        enabled: root.active && root.enabled && (pageStack.columns === 1)
        shortcut: "Esc"
        onTriggered: {
            pageStack.removePages(root)
        }
    }


    headerActions: [
        Action {
            objectName: "share"
            name: "share"

            text: i18n.tr("Share")
            iconName: "share"
            onTriggered: {
                pageStack.addPageToCurrentColumn(root,
                                                 Qt.resolvedUrl("ContactShare/ContactSharePage.qml"),
                                                 {contactModel: root.model,
                                                  contacts: [root.contact]})
            }
        },
        Action {
            objectName: "edit"
            name: "edit"

            text: i18n.tr("Edit")
            iconName: "edit"
            enabled: root.active && !root.editing
            shortcut: "Ctrl+e"
            onTriggered: root.editContact(root.contact)
        }
    ]

    onContactRemoved: pageStack.removePages(root)

    extensions: ContactDetailSyncTargetView {
        contact: root.contact
        anchors {
            left: parent.left
            right: parent.right
        }
        height: implicitHeight
    }

    onActionTrigerred: {
        // "default" action is used inside of the apps (dialer, messaging) to trigger
        // actions based on context.
        // For example default action in the dialer app is call the contact number
        if (action == "default") {
            action = "tel";
        }

        Qt.openUrlExternally(("%1:%2").arg(action).arg(detail.value(0)))
    }

    Loader {
        id: bottomEdgeLoader

        asynchronous: true
        Component.onCompleted: setSource(Qt.resolvedUrl("ABNewContactBottomEdge.qml"),
                                         {"parent": root,
                                          "height": Qt.binding(function () {return root.height}),
                                          "modelToEdit": Qt.binding(function () {return root.model}),
                                          "hint.flickable": Qt.binding(function () {return root.flickable}),
                                          "pageStack": Qt.binding(function () {return root.pageStack}),
                                          "hintVisible": false,
                                          "enabled": Qt.binding(function () {return !root.editing}),
                                          "visible": Qt.binding(function () {return root.pageStack.columns > 1})
                                         })
    }

    Binding {
        target: pageStack
        property: '_bottomEdge'
        value: bottomEdgeLoader.item
        when: (bottomEdgeLoader.status === Loader.Ready) && (pageStack.columns > 1)
    }
}
