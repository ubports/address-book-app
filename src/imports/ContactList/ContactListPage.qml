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
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Contacts 0.1 as ContactsUI
import Ubuntu.Components.Popups 0.1 as Popups
import Ubuntu.Content 0.1 as ContentHub
import "../ContactEdit"
import "../Common"

PageWithBottomEdge {
    id: mainPage
    objectName: "contactListPage"

    property bool pickMode: false
    property alias contentHubTransfer: contactExporter.activeTransfer
    property bool pickMultipleContacts: false
    property var onlineAccountsMessageDialog: null
    property QtObject contactIndex: null
    property bool contactsLoaded: false

    readonly property bool syncEnabled: application.syncEnabled
    readonly property var contactModel: contactList.listModel ? contactList.listModel : null
    readonly property bool searching: (state === "searching")

    function createEmptyContact(phoneNumber) {
        var details = [ {detail: "PhoneNumber", field: "number", value: phoneNumber},
                        {detail: "EmailAddress", field: "emailAddress", value: ""},
                        {detail: "Name", field: "firstName", value: ""}
                      ]

        var newContact =  Qt.createQmlObject("import QtContacts 5.0; Contact{ }", mainPage)
        var detailSourceTemplate = "import QtContacts 5.0; %1{ %2: \"%3\" }"
        for (var i=0; i < details.length; i++) {
            var detailMetaData = details[i]
            var newDetail = Qt.createQmlObject(detailSourceTemplate.arg(detailMetaData.detail)
                                            .arg(detailMetaData.field)
                                            .arg(detailMetaData.value), mainPage)
            newContact.addDetail(newDetail)
        }
        return newContact
    }

    title: contactList.isInSelectionMode ? i18n.tr("Select Contacts") : i18n.tr("Contacts")

    //bottom edge page
    bottomEdgePageComponent: ContactEditor {
        //WORKAROUND: SKD changes the page header as soon as the page get created
        // setting active false will avoid that
        active: false
        enabled: false

        initialFocusSection: "name"
        model: contactList.listModel
        contact: mainPage.createEmptyContact("")
    }
    bottomEdgeTitle: "+"
    bottomEdgeEnabled: !contactList.isInSelectionMode

    Component {
        id: onlineAccountsDialog

        OnlineAccountsMessage {
            id: onlineAccountsMessage
            onCanceled: {
                mainPage.onlineAccountsMessageDialog = null
                PopupUtils.close(onlineAccountsMessage)
                application.unsetFirstRun()
            }
            onAccepted: {
                Qt.openUrlExternally("settings:///system/online-accounts")
                mainPage.onlineAccountsMessageDialog = null
                PopupUtils.close(onlineAccountsMessage)
                application.unsetFirstRun()
            }
        }
    }

    Component {
        id: removeContactDialog

        RemoveContactsDialog {
            id: removeContactsDialogMessage

            onCanceled: {
                PopupUtils.close(removeContactsDialogMessage)
            }

            onAccepted: {
                removeContacts(contactList.listModel)
                PopupUtils.close(removeContactsDialogMessage)
            }
        }
    }

    flickable: null //contactList.fastScrolling ? null : contactList.view
    ContactsUI.ContactListView {
        id: contactList
        objectName: "contactListView"

        anchors {
            top: parent.top
            left: parent.left
            bottom: keyboard.top
            right: parent.right
        }
        contactNameFilter: searchField.text
        detailToPick: ContactDetail.PhoneNumber
        multiSelectionEnabled: true
        multipleSelection: !pickMode ||
                           mainPage.pickMultipleContacts || (contactExporter.active && contactExporter.isMultiple)

        anchors.fill: parent

        leftSideAction: Action {
            iconName: "delete"
            text: i18n.tr("Delete")
            onTriggered: {
                value.makeDisappear()
            }
        }

        onContactDisappeared: {
            if (contact) {
                contactModel.removeContact(contact.contactId)
            }
        }

        onCountChanged: {
            if (count > 0)
                mainPage.contactsLoaded = true

            if ((count > 0) && mainPage.onlineAccountsMessageDialog) {
                // Because of some contacts can take longer to arrive due the dbus delay,
                // we need to destroy the online account dialog if this happen
                PopupUtils.close(mainPage.onlineAccountsMessageDialog)
                mainPage.onlineAccountsMessageDialog = null
                application.unsetFirstRun()
            }

            if (mainPage.searching) {
                 contactList.positionViewAtBeginning()
            }
        }

        onInfoRequested: {
            mainPage.state = ""
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.listModel,
                            contact: contact})
        }

        onDetailClicked: {
            if (action == "call")
                Qt.openUrlExternally("tel:///" + encodeURIComponent(detail.number))
            else if (action == "message")
                Qt.openUrlExternally("message:///" + encodeURIComponent(detail.number))
        }

        onSelectionDone: {
            if (pickMode) {
                var contacts = []
                for (var i=0; i < items.count; i++) {
                    contacts.push(items.get(i).model.contact)
                }
                contactExporter.exportContacts(contacts)
            } else {
                var contacts = []

                for (var i=0, iMax=items.count; i < iMax; i++) {
                    contacts.push(items.get(i).model.contact)
                }

                var dialog = PopupUtils.open(removeContactDialog, null)
                dialog.contacts = contacts
            }
        }

        onSelectionCanceled: {
            if (pickMode) {
                if (contentHubTransfer) {
                    contentHubTransfer.state = ContentTransfer.Aborted
                }
                pageStack.pop()
                application.returnVcard("")
            }
        }

        onError: pageStack.contactModelError(error)
    }

    Column {
        id: indicator

        anchors.centerIn: contactList
        spacing: units.gu(2)
        visible: ((contactList.loading && !mainPage.contactsLoaded) ||
                  (application.syncing && (contactList.count === 0)))


        ActivityIndicator {
            id: activity

            anchors.horizontalCenter: parent.horizontalCenter
            running: indicator.visible
        }
        Label {
            anchors.horizontalCenter: activity.horizontalCenter
            text: contactList.loading ?  i18n.tr("Loading...") : i18n.tr("Syncing...")
        }
    }

    ToolbarItems {
        id: toolbarItemsSelectionMode

        visible: false
        back: ToolbarButton {
            action: Action {
                text: i18n.tr("Cancel selection")
                iconName: "close"
                onTriggered: contactList.cancelSelection()
            }
        }

        ToolbarButton {
            action: Action {
                objectName: "selectAll"
                text: i18n.tr("Select All")
                iconName: "filter"
                onTriggered: {
                    if (contactList.selectedItems.count == contactList.count) {
                        contactList.clearSelection()
                    } else {
                        contactList.selectAll()
                    }
                }
                visible: contactList.isInSelectionMode
            }
        }

        ToolbarButton {
            action: Action {
                objectName: "doneSelection"
                text: mainPage.pickMode ? i18n.tr("Select") : i18n.tr("Delete")
                iconName: mainPage.pickMode ? "select" : "delete"
                onTriggered: contactList.endSelection()
                visible: contactList.isInSelectionMode
            }
        }
    }

    ToolbarItems {
        id: toolbarItemsNormalMode

        visible: false
        ToolbarButton {
            objectName: "Sync"
            action: Action {
                visible: mainPage.syncEnabled
                text: application.syncing ? i18n.tr("Syncing") : i18n.tr("Sync")
                iconName: "reload"
                enabled: !application.syncing
                onTriggered: application.startSync()
            }
        }
        ToolbarButton {
            objectName: "Search"
            action: Action {
                text: i18n.tr("Search")
                visible: !mainPage.searching
                iconName: "search"
                onTriggered: {
                    mainPage.state = "searching"
                    searchField.forceActiveFocus()
                }
            }
        }
    }

    ToolbarItems {
        id: toolbarItemsSearch

        visible: false
        back: ToolbarButton {
            visible: false
            action: Action {
                objectName: "cancelSearch"

                visible: mainPage.searching
                iconName: "back"
                text: i18n.tr("Cancel")
                onTriggered: mainPage.state = ""
            }
        }
    }

    TextField {
        id: searchField

        visible: mainPage.searching
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            topMargin: units.gu(1.5)
            bottomMargin: units.gu(1.5)
            verticalCenter: parent.verticalCenter
        }
        onTextChanged: contactList.currentIndex = -1
        inputMethodHints: Qt.ImhNoPredictiveText
    }

    states: [
        State {
            name: ""
            PropertyChanges {
                target: searchField
                text: ""
            }
        },
        State {
            name: "searching"
            PropertyChanges {
                target: mainPage
                __customHeaderContents: searchField
                tools: toolbarItemsSearch
            }
        },
        State {
            name: "selection"
            when: contactList.isInSelectionMode
            PropertyChanges {
                target: mainPage
                tools: toolbarItemsSelectionMode
            }
        }
    ]

    tools: toolbarItemsNormalMode

    // WORKAROUND: Avoid the gap btw the header and the contact list when the list moves
    // see bug #1296764
    onActiveChanged: {
        contactList.returnToBounds()
    }

    onSyncEnabledChanged: {
        // close online account dialog if any account get registered
        // while the app is running
        if (syncEnabled && mainPage.onlineAccountsMessageDialog) {
            PopupUtils.close(mainPage.onlineAccountsMessageDialog)
            mainPage.onlineAccountsMessageDialog = null
            application.unsetFirstRun()
        }
    }

    // We need to reset the page proprerties in case of the page was created pre-populated,
    // with phonenumber or contact.
    onBottomEdgeDismissed: {
        //WORKAROUND: SKD changes the page header as soon as the page get created
        // setting active false will avoid that
        var newContact = mainPage.createEmptyContact("")
        mainPage.setBottomEdgePage(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   {model: contactList.listModel,
                                    contact: newContact,
                                    active: false,
                                    enabled: false,
                                    initialFocusSection: "name"})
    }

    Connections {
        target: pageStack
        onContactRequested: {
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.listModel, contactId: contactId})
        }
        onCreateContactRequested: {
            var newContact = mainPage.createEmptyContact(phoneNumber)
            //WORKAROUND: SKD changes the page header as soon as the page get created
            // setting active false will avoid that
            mainPage.showBottomEdgePage(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                        {model: contactList.listModel,
                                         contact: newContact,
                                         active: false,
                                         enabled: false,
                                         initialFocusSection: "name"})
        }
        onEditContatRequested: {
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.listModel,
                            contactId: contactId,
                            addPhoneToContact: phoneNumber})
        }
        onContactCreated: {
            mainPage.contactIndex = contact
        }

        onImportContactRequested: {
            var urls = []
            for(var i=0; i < items.length; i++) {
                urls.push(items[i].url)
            }
            if (urls.length > 0) {
                var importDialog = Qt.createQmlObject("VCardImportDialog{}",
                                   mainPage,
                                   "VCardImportDialog")
                if (importDialog) {
                    importDialog.importVCards(contactList.listModel, urls)
                }
            }
        }
    }

    KeyboardRectangle {
        id: keyboard
    }

    Connections {
        target: mainPage.contactModel
        onContactsChanged: {
            if (contactIndex) {
                contactList.positionViewAtContact(mainPage.contactIndex)
                mainPage.contactIndex = null
            }
        }
    }


    QtObject {
        id: contactExporter

        property var activeTransfer: null
        readonly property bool active: activeTransfer && (activeTransfer.state === ContentHub.ContentTransfer.InProgress && activeTransfer.direction === ContentHub.ContentTransfer.Import)
        readonly property bool isMultiple: activeTransfer && (activeTransfer.selectionType === ContentHub.ContentTransfer.Multiple)

        function exportContacts(contacts)
        {
            if (activeTransfer) {
                var exportUrl = "file:///tmp/address_book_app_export.vcf"
                mainPage.contactModel.exportCompleted.connect(contactExporter.onExportCompleted)
                mainPage.contactModel.exportContacts(exportUrl, [], contacts)
            } else {
                console.error("Export requested with noo active transfer")
            }
        }

        function onExportCompleted(error, url)
        {
            mainPage.contactModel.exportCompleted.disconnect(contactExporter.onExportCompleted)
            if (error === ContactModel.ExportNoError) {
                var obj = Qt.createQmlObject("import Ubuntu.Content 0.1;  ContentItem { url: '" + url + "' }", contactExporter)
                activeTransfer.items = [obj]
                activeTransfer.state = ContentHub.ContentTransfer.Charged
            } else {
                console.error("Fail to export contacts:" + error)
            }
            pageStack.pop()
            application.returnVcard(url)
        }
    }

    Component.onCompleted: {
        if (pickMode) {
            contactList.startSelection()
        } else if ((contactList.count === 0) &&
                   application.firstRun &&
                   !mainPage.syncEnabled) {
            mainPage.onlineAccountsMessageDialog = PopupUtils.open(onlineAccountsDialog, null)
        }

        if (TEST_DATA != "") {
            contactList.listModel.importContacts("file://" + TEST_DATA)
        }

        if (!pickMode) {
            mainPage.setBottomEdgePage(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                       {model: contactList.listModel,
                                        contact: mainPage.createEmptyContact(""),
                                        active: false,
                                        enabled: false,
                                        initialFocusSection: "name"})
        }
    }
}
