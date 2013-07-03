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
    id: contactEditor

    property variant contact: null
    property variant model: null

    function edit() {
        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.edit) {
                field.edit()
            }
        }
    }

    function save() {
        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.save) {
                field.save()
            }
        }
    }

    Flickable {
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: contents.height
        contentWidth: parent.width

        Column {
            id: contents

            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ContactHeader {
                contact: contactEditor.contact
                width: parent.width
                height: implicitHeight
            }

            ContactDetailPhoneNumbers {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
            }

            ContactDetailEmails {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
            }

            ContactDetailOnlineAccounts {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
            }

            ContactDetailAddress {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
            }
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: Action {
                text: i18n.tr("Edit")
                onTriggered: {
                    contactEditor.edit()
                    contactEditor.toolbar.opened = false
                }
            }
        }
    }
}
