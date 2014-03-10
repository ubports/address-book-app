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
import Ubuntu.Components 0.1
import QtContacts 5.0
import Ubuntu.Content 0.1
import Ubuntu.Components.Popups 0.1 as Popups

import "../Common"

ContactDetailBase {
    id: root

    readonly property string defaultAvatar: Qt.resolvedUrl("../../artwork/contact-default-profile.png")

    function isEmpty() {
        return false;
    }

    function save() {
        if (avatarImage.source != root.defaultAvatar) {
            if (root.detail && (root.detail === avatarImage.source)) {
                return false
            } else {
                // create the avatar detail
                if (!root.detail) {
                    root.detail = root.contact.avatar
                }
                root.detail.imageUrl = avatarImage.source
                return true
            }
        }
        return false
    }

    function getAvatar(avatarDetail)
    {
        // use this verbose mode to avoid problems with binding loops
        var avatarUrl = root.defaultAvatar

        if (avatarDetail) {
            var avatarValue = avatarDetail.value(Avatar.ImageUrl)
            if (avatarValue != "") {
                avatarUrl = avatarValue
            }
        }
        return avatarUrl
    }

    detail: contact ? contact.detail(ContactDetail.Avatar) : null
    implicitHeight: units.gu(17)

    Image {
        id: avatarImage

        anchors.fill: parent
        source: root.getAvatar(root.detail)
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        // When updating the avatar using the content picker the temporary file returned
        // can contain the same name as the previous one and if the cache is enabled this
        // will cause the image to not be updated
        cache: false

        Component {
            id: loadingDialog

            Popups.Dialog {
                id: dialogue

                title: i18n.tr("Loading")

                ActivityIndicator {
                    id: activity

                    anchors.centerIn: parent
                    running: true
                    visible: running
                }
            }
        }

        Icon {
            anchors {
                right: parent.right
                rightMargin: units.gu(1.5)
                bottom: parent.bottom
                bottomMargin: units.gu(2)
            }
            width: units.gu(3)
            height: width
            name: "import-image"
            color: "white"
        }

        MouseArea {
            id: changeButton

            property var activeTransfer
            property var loadingDialog: null

            anchors.fill: parent
            onClicked: {
                // make sure the OSK disappear
                root.forceActiveFocus()
                if (!changeButton.loadingDialog) {
                    changeButton.loadingDialog = PopupUtils.open(loadingDialog, null)
                    changeButton.activeTransfer = ContentHub.importContent(ContentType.Pictures,
                                                                           ContentHub.defaultSourceForType(ContentType.Pictures));
                    changeButton.activeTransfer.start();
                }
            }

            Connections {
                target: changeButton.activeTransfer != null ? changeButton.activeTransfer : null
                onStateChanged: {
                    var done = ((changeButton.activeTransfer.state === ContentTransfer.Charged) ||
                                (changeButton.activeTransfer.state === ContentTransfer.Aborted));

                    if (changeButton.activeTransfer.state === ContentTransfer.Charged) {
                        if (changeButton.activeTransfer.items.length > 0) {
                            // remove the previous image, this is nessary to make sure that the new image
                            // get updated otherwise if the new image has the same name the image will not
                            // be updated
                            avatarImage.source = ""
                            // Update with the new valu
                            avatarImage.source = application.copyImage(root.contact, changeButton.activeTransfer.items[0].url);
                        }
                    }

                    if (done) {
                        PopupUtils.close(changeButton.loadingDialog)
                        changeButton.loadingDialog = null
                    }
                }
            }
        }
    }
}

