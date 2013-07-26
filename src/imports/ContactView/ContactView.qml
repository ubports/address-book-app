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
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: root

    readonly property alias contact: contactFetch.contact
    property variant contactId: null
    property alias model: contactFetch.model

    function formatNameToDisplay(contact) {
        if (!contact) {
            return ""
        }

        if (contact.name) {
            var detail = contact.name
            return detail.firstName + "\n" + detail.lastName
        } else if (contact.displayLabel && contact.displayLabel.label && contact.displayLabel.label !== "") {
            return contact.displayLabel.label
        } else {
            return ""
        }
    }


    title: formatNameToDisplay(contact)
    onActiveChanged: {
        if (active) {
            contactFetch.fetchContact(root.contactId)
        }
    }

    Flickable {
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: contents.height
        contentWidth: parent.width
        visible: !busyIndicator.visible

        Column {
            id: contents

            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ContactDetailAvatarView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailPhoneNumbersView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailEmailsView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOnlineAccountsView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailAddressesView {
                contact: root.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

        }
    }

    ActivityIndicator {
        id: busyIndicator

        running: contactFetch.running
        visible: running
        anchors.centerIn: parent
    }

    ContactFetch {
        id: contactFetch
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: Action {
                text: i18n.tr("Delete")
                iconSource: "artwork:/delete.png"
                onTriggered: {
                    root.model.removeContact(root.contact.contactId)
                    pageStack.pop()
                }
            }
        }
        ToolbarButton {
            action: Action {
                text: i18n.tr("Edit")
                iconSource: "artwork:/edit.png"
                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   { model: root.model, contact: root.contact})
                }
            }
        }
    }
}
