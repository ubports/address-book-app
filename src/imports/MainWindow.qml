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

import QtQuick 2.2
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1 as Popups
import Ubuntu.Content 0.1 as ContentHub

MainView {
    id: mainWindow

    property string modelErrorMessage: ""
    readonly property bool appActive: Qt.application.active

    width: units.gu(40)
    height: units.gu(71)
    anchorToKeyboard: false
    useDeprecatedToolbar: false

    signal applicationReady()

    function contact(contactId)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.showContact(contactId)
        }
    }

    function create(phoneNumber)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.createContactWithPhoneNumber(phoneNumber)
        }
    }

    function addphone(contactId, phoneNumber)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.addPhoneToContact(contactId, phoneNumber)
        }
    }

    function pick(single)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.startPickMode(single == "true")
        }
    }

    function importvcard(_url)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.importContactRequested([_url])
        }
    }

    function addnewphone(phoneNumer)
    {
        mainStack.resetStack()
        if (mainStack.contactListPage) {
            mainStack.contactListPage.addNewPhone(phoneNumer)
        }
    }

    PageStack {
        id: mainStack

        property var contactListPage: null

        function resetStack()
        {
            while(depth > 1) {
                pop()
            }
        }

        anchors.fill: parent
    }

    Component.onCompleted: {
        i18n.domain = "address-book-app"
        i18n.bindtextdomain("address-book-app", i18nDirectory)
        mainStack.push(Qt.createComponent("ContactList/ContactListPage.qml"))
        mainWindow.applicationReady()
    }

    Component {
        id: errorDialog

        Popups.Dialog {
            id: dialogue

            title: i18n.tr("Error")
            text: mainWindow.modelErrorMessage

            Button {
                text: "Cancel"
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

    Connections {
        target: ContentHub.ContentHub
        onExportRequested: {
            // enter in pick mode
            mainStack.push(Qt.createComponent("ContactList/ContactListPage.qml"),
                           {pickMode: true,
                            contentHubTransfer: transfer})
        }
        onImportRequested: {
            if (transfer.state === ContentHub.ContentTransfer.Charged) {
                var urls = []
                for(var i=0; i < transfer.items.length; i++) {
                    urls.push(transfer.items[i].url)
                }
                mainStack.importContactRequested(urls)
            }
        }
    }


    // If application was called from uri handler and lost the focus reset the app to normal state
    onAppActiveChanged: {
        if (!appActive && mainStack.contactListPage) {
            mainStack.contactListPage.returnToNormalState()
        }
    }
}
