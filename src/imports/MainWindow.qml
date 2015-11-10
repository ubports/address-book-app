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

MainView {
    id: mainWindow
    objectName: "addressBookAppMainWindow"

    property string modelErrorMessage: ""
    readonly property bool appActive: Qt.application.active

    signal applicationReady()

    function contact(contactId)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.showContactWithId(contactId)
        } else {
            console.error("Contact preview requested but ContactListPage not loaded")
        }
    }

    function create(phoneNumber)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.createContactWithPhoneNumber(phoneNumber)
        } else {
            console.error("Contact creation requested but ContactListPage not loaded")
        }
    }

    function addphone(contactId, phoneNumber)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.addPhoneToContact(contactId, phoneNumber)
        } else {
            console.error("Add phone to contact requested but ContactListPage not loaded")
        }
    }

    function pick(single)
    {
        console.debug("Pick mode:" + single)
        pickWithTransfer(single === "true", null)
    }

    function pickWithTransfer(single, activeTransfer)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.startPickMode(single, activeTransfer)
        } else {
            console.error("Pick mode requested but ContactListPage not loaded")
        }
    }

    function importvcard(_url)
    {
        importvcards([_url])
    }

    function importvcards(_urls)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.importContact(_urls)
        } else {
            console.error("Import vcard requested but ContactListPage not loaded")
        }
    }

    function addnewphone(phoneNumer)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.addNewPhone(phoneNumer)
        } else {
            console.error("Add new phone requested but ContactListPage not loaded")
        }
    }

    width: units.gu(90)
    height: units.gu(71)
    anchorToKeyboard: false
    focus: false

    AdaptivePageLayout {
        id: mainStack

        primaryPage: contactPage
        focus: false
        property var contactListPage: null

        function resetStack()
        {
            mainStack.removePages(primaryPage);
        }

        onContactListPageChanged: {
            if (contentHubLoader.status === Loader.Ready) {
                contentHubLoader.item.pageStack = mainStack
            } else {
                contentHubLoader.setSource(Qt.resolvedUrl("ContentHubProxy.qml"), {"pageStack": mainStack})
            }
        }

        anchors.fill: parent
        layouts: [
            PageColumnsLayout {
                when: mainStack.width >= units.gu(80)
                PageColumn {
                    maximumWidth: units.gu(50)
                    minimumWidth: units.gu(40)
                    preferredWidth: units.gu(40)
                }
                PageColumn {
                    fillWidth: true
                }
            },
            PageColumnsLayout {
                when: true
                PageColumn {
                    fillWidth: true
                }
            }
        ]

    }

    ABContactListPage {
        id: contactPage
        pageStack: mainStack
    }

    Component.onCompleted: {
        application.elapsed()
        i18n.domain = "address-book-app"
        i18n.bindtextdomain("address-book-app", i18nDirectory)
        mainWindow.applicationReady()
    }

    Component {
        id: errorDialog

        Popups.Dialog {
            id: dialogue

            title: i18n.tr("Error")
            text: mainWindow.modelErrorMessage

            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    Connections {
        target: UriHandler
        onOpened: {
            for (var i = 0; i < uris.length; ++i) {
                application.parseUrl(uris[i])
            }
        }
    }

    Loader {
        id: contentHubLoader

        //We can not use async load, the export requested signal can be received before the component get ready
        //asynchronous: true
        source: Qt.resolvedUrl("ContentHubProxy.qml")
        onStatusChanged: {
            if (status === Loader.Ready) {
                item.pageStack = mainStack
            }
        }
    }

    // If application was called from uri handler and lost the focus reset the app to normal state
    onAppActiveChanged: {
        if (appActive) {
            mainStack.forceActiveFocus()
        }

        if (!appActive && mainStack.contactListPage) {
            mainStack.contactListPage.returnToNormalState()
        }
    }

    Keys.onPressed: {
        var prev = mainWindow.nextItemInFocusChain(false)
        var next = mainWindow.nextItemInFocusChain(true)
        console.debug("Next:" + next)
        console.debug("Prev:" + prev)

        console.debug("Key pressed Main: " + event)
    }

}
