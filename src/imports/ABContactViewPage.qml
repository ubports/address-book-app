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

    function editContact(contact)
    {
        pageStack.addPageToCurrentColumn(root,
                                         Qt.resolvedUrl("ABContactEditorPage.qml"),
                                         { model: root.model,
                                           contact: contact,
                                           backIconName: 'back'})
    }

    head.actions: [
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
            enabled: root.active
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

        active: root.pageStack &&  root.pageStack.columns > 1
        sourceComponent: ABNewContactBottomEdge {
            id: bottomEdge

            parent: root
            pageStack: root.pageStack
            modelToEdit: root.model
            hint.flickable: root.flickable
        }

        Binding {
            target: pageStack
            property: 'bottomEdge'
            value: bottomEdgeLoader.item
            when: bottomEdgeLoader.status == Loader.Ready
        }
    }

    Component.onDestruction:  console.debug("VIEW DESTROYED")
}
