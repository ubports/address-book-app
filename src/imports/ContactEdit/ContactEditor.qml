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

    // FIXME: this is necessary due a bug on SDK
    // Until now is impossible to mix pages with and without title
    title: i18n.tr("Edit contact")

    property QtObject contact: null
    property QtObject model: null

    function save() {
        var changed = false
        for(var i = 0; i < contents.children.length; ++i) {
            var field = contents.children[i]
            if (field.save) {
                if (field.save()) {
                    changed = true
                }
            }
        }

        if (changed) {
            model.saveContact(contact)
        } else {
            pageStack.pop()
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

            spacing: units.gu(1)

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: units.gu(1)
            }
            height: childrenRect.height

            ContactDetailNameEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailAvatarEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailPhoneNumbersEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailEmailsEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailOnlineAccountsEditor {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: implicitHeight
            }

            ContactDetailAddressesEditor {
                contact: contactEditor.contact
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

        running: contactSaveLock.saving
        visible: running
        anchors.centerIn: parent
    }

    Connections {
        id: contactSaveLock

        property bool saving: false

        target: contactEditor.model

        onContactsChanged: {
            if (saving) {
                pageStack.pop()
            }
        }

        onErrorChanged: {
            //TODO: show a dialog
            console.debug("Save error:" + contactEditor.model.error)
        }
    }

    tools: ToolbarItems {
        locked: true

        ToolbarButton {
            action: Action {
                text: i18n.tr("Done")
                iconSource: "artwork:/save.png"
                onTriggered: {
                    // wait for contact to be saved or cause a error
                    contactSaveLock.saving = true
                    contactEditor.save()
                }
            }
        }
    }
}
