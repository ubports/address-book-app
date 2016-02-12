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
import Ubuntu.AddressBook.ContactShare 0.1

ContactViewPage {
    id: root
    objectName: "contactViewPage"

    property bool editing: false
    // used by autopilot test
    readonly property string headerTitle: header.title

    // FIXME: bug #1544745
    // Adaptive layout is not destroying all pages correct, we do it manually for now
    property var _editPage: null
    function cancelEdit()
    {
        if (_editPage) {
            pageStack.removePages(_editPage)
            _editPage = null
        }
    }

    function editContact(contact)
    {
        if (editing)
            return
        editing = true
        var component = Qt.createComponent(Qt.resolvedUrl("ABContactEditorPage.qml"))
        var incubator = pageStack.addPageToCurrentColumn(root,
                                                         component,
                                                         { model: root.model,
                                                           contact: contact,
                                                           backIconName: 'back'})
        if (incubator && (incubator.status === Component.Loading)) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    root._editPage = incubator.object
                    incubator.object.Component.destruction.connect(function() {
                        root._editPage = null;
                        root.editing = false;
                    });
                }
            }
        } else {
            editing = false
        }
    }

    // Shortcut in case of single column
     Action {
        id: backAction

        name: "cancel"
        enabled: root.active && root.enabled && (pageStack.columns === 1)
        shortcut: "Esc"
        onTriggered: {
            pageStack.removePage(root)
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
                                                 contactShareComponent,
                                                 {contactModel: root.model,
                                                  contacts: [root.contact]})
            }
        },
        Action {
            objectName: "edit"
            name: "edit"

            text: i18n.tr("Edit")
            iconName: "edit"
            enabled: root.active && !editing
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

    Component {
        id: contactShareComponent
        ContactSharePage {}
    }

    Loader {
        id: bottomEdgeLoader

        active: (pageStack.columns > 1)
        asynchronous: true
        sourceComponent: ABNewContactBottomEdge {
            id: bottomEdge

            parent: root
            height: root.height
            modelToEdit: root.model
            hint.flickable: root.flickable
            pageStack: root.pageStack
            hintVisible: false
            enabled: !root.editing
        }
    }

    Binding {
        target: pageStack
        property: 'bottomEdge'
        value: bottomEdgeLoader.item
        when: bottomEdgeLoader.status === Loader.Ready
    }
}
