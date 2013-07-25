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

    function makeMeVisible(item) {
        console.debug("Item requested visibility:" + item)
        var position = scrollArea.contentItem.mapFromItem(item, 0, item.y);

        // check if the item is already visible
        var bottomY = scrollArea.contentY + scrollArea.height
        var itemBottom = position.y + item.height
        if (position.y >= scrollArea.contentY && itemBottom <= bottomY) {
            return;
        }

        // if it is not, try to scroll and make it visible
        var targetY = position.y + item.height - scrollArea.height
        if (targetY >= 0 && position.y) {
            scrollArea.contentY = targetY;
        } else if (position.y < scrollArea.contentY) {
            // if it is hidden at the top, also show it
            scrollArea.contentY = position.y;
        }
    }

    flickable: null
    Flickable {
        id: scrollArea

        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: contents.height
        contentWidth: parent.width
        visible: !busyIndicator.visible

        Column {
            id: contents

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: childrenRect.height

            ContactDetailNameEditor {
                id: nameEditor

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

    Component.onCompleted: nameEditor.forceActiveFocus()

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
        opened: true
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
