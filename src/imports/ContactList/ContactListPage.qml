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

import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0 as Popups
import Ubuntu.Contacts 0.1 as ContactsUI
import Ubuntu.Content 0.1 as ContentHub

import "../Common"

ContactsUI.PageWithBottomEdge {
    id: mainPage
    objectName: "contactListPage"

    property bool pickMode: false
    property alias contentHubTransfer: contactExporter.activeTransfer
    property bool pickMultipleContacts: false
    property var onlineAccountsMessageDialog: null
    property QtObject contactIndex: null
    property bool contactsLoaded: false
    property string newPhoneToAdd: ""

    readonly property bool allowToQuit: (application.callbackApplication.length > 0)
    readonly property bool syncEnabled: application.syncEnabled
    readonly property var contactModel: contactList.listModel ? contactList.listModel : null
    readonly property bool searching: (state === "searching" || state === "newphoneSearching")

    // this function is used to reset the contact list page to the default state if it was called
    // from the uri. For example when called to add a new contact
    function returnToNormalState()
    {
        // these two states are the only state that need to be reset
        if (state == "newphoneSearching" || state == "newphone") {
            state = "default"
        }
        application.callbackApplication = ""
    }

    function createEmptyContact(phoneNumber)
    {
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

    function createContactWithPhoneNumber(phoneNumber)
    {
        var newContact = mainPage.createEmptyContact(phoneNumber)
        //WORKAROUND: SKD changes the page header as soon as the page get created
        // setting active false will avoid that
        if (bottomEdgeEnabled) {
            mainPage.showBottomEdgePage(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                        {model: contactList.listModel,
                                         contact: newContact,
                                         active: false,
                                         enabled: false,
                                         initialFocusSection: "name"})
        } else {
            pageStack.push(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                           {model: contactList.listModel,
                            contact: newContact,
                            initialFocusSection: "name"})
        }
    }

    function showContact(contactId)
    {
        pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                       {model: contactList.listModel, contactId: contactId})
    }

    function addPhoneToContact(contactId, phoneNumber)
    {
        pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                       {model: contactList.listModel,
                        contactId: contactId,
                        addPhoneToContact: phoneNumber})
    }

    function importContact(urls)
    {
        if (urls.length > 0) {
            var importDialog = Qt.createQmlObject("VCardImportDialog{}",
                               mainPage,
                               "VCardImportDialog")
            if (importDialog) {
                importDialog.importVCards(contactList.listModel, urls)
            }
        }
    }

    function startPickMode(isSingleSelection, activeTransfer)
    {
        contentHubTransfer = activeTransfer
        pickMode = true
        pickMultipleContacts = !isSingleSelection
        contactList.startSelection()
    }

    function moveListToContact(contact)
    {
        contactIndex = contact
        mainPage.state = "default"
        // this means a new contact was created
        if (mainPage.allowToQuit) {
            application.goBackToSourceApp()
        }
    }

    function addNewPhone(phoneNumber)
    {
        newPhoneToAdd = phoneNumber
        state = "newphone"
        contactList.reset()
    }

    title: i18n.tr("Contacts")
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

    flickable: null
    ContactsUI.ContactListView {
        id: contactList
        objectName: "contactListView"

        header:  Item {
            id: addNewContactButton
            objectName: "addNewContact"

            anchors {
                left: parent.left
                right: parent.right
            }
            visible: false
            height: visible ? units.gu(8) : 0

            Rectangle {
                anchors.fill: parent
                color: Theme.palette.selected.background
                opacity: addNewContactButtonArea.pressed ?  1.0 : 0.0
            }

            UbuntuShape {
                id: addIcon

                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: units.gu(1)
                }
                width: height
                radius: "medium"
                color: Theme.palette.normal.overlay
                Image {
                    anchors.centerIn: parent
                    width: units.gu(2)
                    height: units.gu(2)
                    source: "image://theme/add"
                }
            }

            Label {
                id: name

                anchors {
                    left: addIcon.right
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: units.gu(2)
                }
                color: UbuntuColors.lightAubergine
                // TRANSLATORS: this refers to creating a new contact
                text: i18n.tr("+ Create New")
                elide: Text.ElideRight
            }

            MouseArea {
                id: addNewContactButtonArea

                anchors.fill: parent
                onClicked: mainPage.createContactWithPhoneNumber(mainPage.newPhoneToAdd)
            }
        }

        anchors {
            top: parent.top
            left: parent.left
            bottom: keyboard.top
            right: parent.right
        }
        filterTerm: searchField.text
        detailToPick: ContactDetail.PhoneNumber
        multiSelectionEnabled: true
        multipleSelection: !pickMode ||
                           mainPage.pickMultipleContacts ||
                           (contactExporter.active && contactExporter.isMultiple)

        leftSideAction: Action {
            iconName: "delete"
            text: i18n.tr("Delete")
            onTriggered: value.remove()
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
        }

        onAddContactClicked: mainPage.createContactWithPhoneNumber(label)

        onInfoRequested: {
            mainPage.state = "default"
            pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                           {model: contactList.listModel,
                            contact: contact})
        }

        onDetailClicked: {
            if (action == "call")
                Qt.openUrlExternally("tel:///" + encodeURIComponent(detail.number))
            else if (action == "message")
                Qt.openUrlExternally("message:///" + encodeURIComponent(detail.number))
            else if ((mainPage.state === "newphone") || (mainPage.state === "newphoneSearching")) {
                mainPage.addPhoneToContact(contact.contactId, mainPage.newPhoneToAdd)
            }
        }

        onAddDetailClicked: mainPage.addPhoneToContact(contact.contactId, " ")

        onIsInSelectionModeChanged: mainPage.state = isInSelectionMode ? "selection"  : "default"
        onSelectionCanceled: {
            if (pickMode) {
                if (contentHubTransfer) {
                    contentHubTransfer.state = ContentHub.ContentTransfer.Aborted
                }
                pickMode = false
                contentHubTransfer = null
                application.returnVcard("")
            }
            mainPage.state = "default"
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

    TextField {
        id: searchField

        anchors {
            left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
        }
        visible: mainPage.searching
        onTextChanged: contactList.currentIndex = -1
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search...")
    }

    Connections {
        target: mainPage.head.sections
        onSelectedIndexChanged: {
            switch (mainPage.head.sections.selectedIndex) {
            case 0:
                contactList.showAllContacts()
                break;
            case 1:
                contactList.showFavoritesContacts()
                break;
            default:
                break;
            }
        }
    }

    state: "default"
    states: [
        PageHeadState {
            id: defaultState

            name: "default"
            backAction: Action {
                visible: mainPage.allowToQuit
                iconName: "back"
                text: i18n.tr("Quit")
                onTriggered: {
                    application.goBackToSourceApp()
                    mainPage.returnToNormalState()
                }
            }
            actions: [
                Action {
                    visible: mainPage.syncEnabled
                    text: application.syncing ? i18n.tr("Syncing") : i18n.tr("Sync")
                    iconName: "reload"
                    enabled: !application.syncing
                    onTriggered: application.startSync()
                },
                Action {
                    text: i18n.tr("Search")
                    iconName: "search"
                    onTriggered: {
                        mainPage.state = (mainPage.state === "newphone" ? "newphoneSearching" : "searching")
                        contactList.showAllContacts()
                        searchField.forceActiveFocus()
                    }
                }
            ]
            PropertyChanges {
                target: mainPage.head
                backAction: defaultState.backAction
                actions: defaultState.actions
                // TRANSLATORS: this refers to all contacts
                sections.model: [i18n.tr("All"), i18n.tr("Favorites")]
            }
            PropertyChanges {
                target: searchField
                text: ""
            }
        },
        PageHeadState {
            id: searchingState

            name: "searching"
            backAction: Action {
                iconName: "close"
                text: i18n.tr("Cancel")
                onTriggered: {
                    contactList.forceActiveFocus()
                    mainPage.head.sections.selectedIndex = 0
                    mainPage.state = (mainPage.state === "newphoneSearching" ? "newphone" : "default")
                }
            }

            PropertyChanges {
                target: mainPage.head
                backAction: searchingState.backAction
                contents: searchField
            }

            PropertyChanges {
                target: searchField
                text: ""
            }
        },
        PageHeadState {
            id: selectionState

            name: "selection"
            backAction: Action {
                text: i18n.tr("Cancel selection")
                iconName: "close"
                onTriggered: contactList.cancelSelection()
            }
            actions: [
                Action {
                    text: i18n.tr("Select All")
                    iconName: "select"
                    onTriggered: {
                        if (contactList.selectedItems.count === contactList.count) {
                            contactList.clearSelection()
                        } else {
                            contactList.selectAll()
                        }
                    }
                    visible: contactList.isInSelectionMode
                },
                Action {
                    objectName: "share"
                    text: i18n.tr("Share")
                    iconName: "share"
                    visible: contactList.isInSelectionMode
                    onTriggered: {
                        var contacts = []
                        var items = contactList.selectedItems

                        for (var i=0, iMax=items.count; i < iMax; i++) {
                            contacts.push(items.get(i).model.contact)
                        }

                        if (mainPage.pickMode) {
                            contactExporter.exportContacts(contacts)
                            mainPage.pickMode = false
                        } else {
                            pageStack.push(Qt.resolvedUrl("../ContactShare/ContactSharePage.qml"),
                                           { contactModel: contactList.listModel, contacts: contacts })
                        }
                        contactList.endSelection()
                    }
                },
                Action {
                    objectName: "delete"
                    text: i18n.tr("Delete")
                    iconName: "delete"
                    visible: contactList.isInSelectionMode && !mainPage.pickMode
                    onTriggered: {
                        var contacts = []
                        var items = contactList.selectedItems

                        for (var i=0, iMax=items.count; i < iMax; i++) {
                            contacts.push(items.get(i).model.contact)
                        }

                        var dialog = PopupUtils.open(removeContactDialog, null)
                        dialog.contacts = contacts
                        contactList.endSelection()
                    }
                }
            ]
            PropertyChanges {
                target: mainPage.head
                backAction: selectionState.backAction
                actions: selectionState.actions
            }
            PropertyChanges {
                target: mainPage
                bottomEdgeEnabled: false
                title: " "
            }
        },
        PageHeadState {
            name: "newphone"
            extend: "default"
            head: mainPage.head
            PropertyChanges {
                target: addNewContactButton
                visible: true
            }
            PropertyChanges {
                target: mainPage
                bottomEdgeEnabled: false
                title: i18n.tr("Add contact")
            }
            PropertyChanges {
                target: contactList
                detailToPick: -1
            }
        },
        PageHeadState {
            name: "newphoneSearching"
            extend: "searching"
            head: mainPage.head
            PropertyChanges {
                target: addNewContactButton
                visible: true
            }
            PropertyChanges {
                target: contactList
                detailToPick: -1
            }
            PropertyChanges {
                target: mainPage
                bottomEdgeEnabled: false
            }
        }
    ]
    onActiveChanged: {
        if (active && addNewContactButton.visible) {
            contactList.positionViewAtBeginning()
        }
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
            activeTransfer = null
            pickMode = false
            mainPage.state = "defautl"
            application.returnVcard(url)
        }
    }

    Component.onCompleted: {
        application.elapsed()
        if ((contactList.count === 0) &&
                   application.firstRun &&
                   !mainPage.syncEnabled) {
            mainPage.onlineAccountsMessageDialog = PopupUtils.open(onlineAccountsDialog, null)
        }

        if (TEST_DATA !== "") {
            contactList.listModel.importContacts("file://" + TEST_DATA)
        }

        mainPage.setBottomEdgePage(Qt.resolvedUrl("../ContactEdit/ContactEditor.qml"),
                                   {model: contactList.listModel,
                                    contact: mainPage.createEmptyContact(""),
                                    active: false,
                                    enabled: false,
                                    initialFocusSection: "name"})
        pageStack.contactListPage = mainPage
    }
}
