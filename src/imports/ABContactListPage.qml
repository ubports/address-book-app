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
import QtContacts 5.0

import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3 as Popups
import Ubuntu.Contacts 0.1 as ContactsUI
import Ubuntu.Content 1.1 as ContentHub

import Ubuntu.AddressBook.Base 0.1
import Ubuntu.AddressBook.ContactShare 0.1

import "." as AB

Page {
    id: mainPage
    objectName: "contactListPage"

    property bool pickMode: false
    property alias contentHubTransfer: contactExporter.activeTransfer
    property bool pickMultipleContacts: false
    property QtObject contactIndex: null
    property string newPhoneToAdd: ""
    property alias contactManager: contactList.manager
    property Page contactViewPage: null
    property Page contactEditorPage: null
    property var _busyDialog: null
    property bool _importingTestData: false

    readonly property bool bottomEdgePageOpened: bottomEdge.opened && bottomEdge.fullLoaded
    readonly property bool isEmpty: (contactList.count === 0)
    readonly property bool allowToQuit: (application.callbackApplication.length > 0)
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

    function createContactWithPhoneNumber(phoneNumber)
    {
        var newContact = ContactsJS.createEmptyContact(phoneNumber, mainPage);
        openEditPage({model: contactList.listModel,
                      contact: newContact,
                      initialFocusSection: "name"},
                     mainPage);
    }

    function openEditPage(editPageProperties, sourcePage) {
        var component = Qt.createComponent(Qt.resolvedUrl("ABContactEditorPage.qml"))
        if (component.status === Component.Ready) {
            mainPage.contactEditorPage = component.createObject(mainPage, editPageProperties)
            pageStack.addPageToNextColumn(sourcePage, mainPage.contactEditorPage)
        }
    }

    function openViewPage(viewPageProperties) {
        var component = Qt.createComponent(Qt.resolvedUrl("ABContactViewPage.qml"))
        if (component.status === Component.Ready) {
            mainPage.contactViewPage = component.createObject(mainPage, viewPageProperties)
            pageStack.addPageToNextColumn(mainPage, mainPage.contactViewPage)
        }
    }

    function showContact(contact)
    {
        // go back to normal state if not searching
        if ((state !== "searching") &&
            (state !== "vcardImported")) {
            mainPage.state = "default";
        }
        openViewPage({model: contactList.listModel,
                      contact: contact});
    }

    function showContactWithId(contactId)
    {
        openViewPage({model: contactList.listModel,
                      contactId: contactId});
    }

    function addPhoneToContact(contactId, phoneNumber)
    {
        openViewPage({model: contactList.listModel,
                      contactId: contactId,
                      addPhoneToContact: phoneNumber});
    }

    function importContact(urls)
    {
        mainPage._busyDialog = PopupUtils.open(busyDialogComponent, mainPage)

        var importing = false
        for(var i=0, iMax=urls.length; i < iMax; i++) {
            var url = urls[i]
            if (url && url != "") {
                importing = true
                contactList.listModel.importContacts(url)
            }
        }

        if (!importing) {
            PopupUtils.close(mainPage._busyDialog)
            mainPage._busyDialog = null
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
        // skipt it if searching or importing contacts
        if ((state === "searching") ||
            (state === "vcardImported")) {
            return
        }

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

    function showContactEditorPage(editorPage) {
        contactList.currentIndex = -1;
        mainPage.contactEditorPage = editorPage;
        pageStack.addPageToNextColumn(mainPage, editorPage);
        editorPage.ready();
        editorPage.contactSaved.connect(onNewContactSaved);
    }

    function onNewContactSaved(contact) {
        if (pageStack.columns > 1) {
            showContact(contact);
        }
    }

    title: i18n.tr("Contacts")

    flickable: null
    ContactsUI.ContactListView {
        id: contactList
        objectName: "contactListView"
        showImportOptions:  !mainPage.pickMode &&
                            mainPage.newPhoneToAdd === "" &&
                            (!mainPage.contactEditorPage || !mainPage.contactEditorPage.active)
        anchors {
            top: parent.top
            left: parent.left
            bottom: keyboard.top
            right: parent.right
        }
        filterTerm: searchField.text
        multiSelectionEnabled: true
        multipleSelection: (mainPage.pickMode && mainPage.pickMultipleContacts) || !mainPage.pickMode
        highlightSelected: pageStack.columns > 1
        onAddContactClicked: mainPage.createContactWithPhoneNumber(label)
        onAddNewContactClicked: mainPage.createContactWithPhoneNumber(mainPage.newPhoneToAdd)

        onContactClicked: mainPage.showContact(contact)
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

    TextField {
        id: searchField

        anchors {
            left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
        }
        focus: false
        visible: false
        onTextChanged: contactList.currentIndex = -1
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search...")
        onFocusChanged: {
            if (visible && focus)
                searchField.forceActiveFocus()
        }
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
                    text: i18n.tr("Search")
                    iconName: "search"
                    visible: !mainPage.isEmpty
                    onTriggered: {
                        mainPage.state = (mainPage.state === "newphone" ? "newphoneSearching" : "searching")
                        contactList.showAllContacts()
                        searchField.forceActiveFocus()
                    }
                },
                Action {
                    visible: (application.isOnline && (contactList.syncEnabled || application.serverSafeMode))
                    text: contactList.syncing ? i18n.tr("Syncing") : i18n.tr("Sync")
                    iconName: application.serverSafeMode ? "reset" : "reload"
                    enabled: !contactList.syncing && !application.updating
                    onTriggered: {
                        if (application.serverSafeMode) {
                            application.startUpdate()
                        } else {
                            contactList.sync()
                        }
                    }
                },
                Action {
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: pageStack.addPageToNextColumn(mainPage,
                                                               Qt.resolvedUrl("./Settings/SettingsPage.qml"),
                                                               {"contactListModel": contactList.listModel})
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
                iconName: "back"
                text: i18n.tr("Cancel")
                onTriggered: {
                    contactList.forceActiveFocus()
                    mainPage.head.sections.selectedIndex = 0
                    mainPage.state = (mainPage.state === "newphoneSearching" ? "newphone" : "default")
                }
            }

            PropertyChanges {
                target: bottomEdge
                enabled: false
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

            PropertyChanges {
                target: searchField
                visible: true
                focus: true
            }
        },
        PageHeadState {
            id: selectionState

            name: "selection"
            backAction: Action {
                text: i18n.tr("Cancel selection")
                iconName: "back"
                onTriggered: contactList.cancelSelection()
            }
            actions: [
                Action {
                    text: (contactList.selectedItems.count === contactList.count) ? i18n.tr("Unselect All") : i18n.tr("Select All")
                    iconName: "select"
                    onTriggered: {
                        if (contactList.selectedItems.count === contactList.count) {
                            contactList.clearSelection()
                        } else {
                            contactList.selectAll()
                        }
                    }
                    visible: contactList.multipleSelection && !mainPage.isEmpty
                },
                Action {
                    objectName: "share"
                    text: i18n.tr("Share")
                    iconName: mainPage.pickMode ? "tick" : "share"
                    enabled: (contactList.selectedItems.count > 0)
                    visible: contactList.isInSelectionMode
                    onTriggered: {
                        var contacts = []
                        var items = contactList.selectedItems

                        for (var i=0, iMax=items.count; i < iMax; i++) {
                            contacts.push(items.get(i).model.contact)
                        }
                        contactExporter.start(contacts)
                        contactList.endSelection()
                    }
                },
                Action {
                    objectName: "delete"
                    text: i18n.tr("Delete")
                    iconName: "delete"
                    enabled: (contactList.selectedItems.count > 0)
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
                target: bottomEdge
                enabled: false
            }
        },
        PageHeadState {
            name: "newphone"
            extend: "default"
            head: mainPage.head
            PropertyChanges {
                target: contactList
                showAddNewButton: true
            }
            PropertyChanges {
                target: mainPage
                title: i18n.tr("Add contact")
            }
            PropertyChanges {
                target: bottomEdge
                enabled: false
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
                target: contactList
                detailToPick: -1
                showAddNewButton: true
            }
            PropertyChanges {
                target: bottomEdge
                enabled: false
            }
        },
        PageHeadState {
            id: vcardImportedState

            name: "vcardImported"
            backAction: Action {
                iconName: "back"
                text: i18n.tr("Back")
                onTriggered: {
                    contactList.forceActiveFocus()
                    mainPage.state = "default"
                    importedIdsFilter.ids = []
                }
            }
            PropertyChanges {
                target: mainPage.head
                backAction: vcardImportedState.backAction
            }
            PropertyChanges {
                target: bottomEdge
                enabled: false
            }
            PropertyChanges {
                target: mainPage
                title: i18n.tr("Imported contacts")
            }
        }
    ]

    //WORKAROUND: we need to call 'changeFilter' manually to make sure that the model will be cleared
    // before update it with the new model. This is faster than do a match of contacts
    transitions: [
         Transition {
            from: "vcardImported"
            ScriptAction {
                script: contactList.listModel.changeFilter(null)
            }
        },
        Transition {
            to: "vcardImported"
            ScriptAction {
                script: contactList.listModel.changeFilter(importedIdsFilter)
            }
        }
    ]

    onActiveChanged: {
        if (active && contactList.showAddNewButton) {
            contactList.positionViewAtBeginning()
        }
        if (active && (state === "searching")) {
            searchField.forceActiveFocus()
        }
    }

    IdFilter {
        id: importedIdsFilter
    }

    KeyboardRectangle {
        id: keyboard
    }

    Column {
        id: emptyStateScreen

        anchors.centerIn: parent
        height: childrenRect.height
        width: childrenRect.width
        spacing: units.gu(2)
        visible: (!contactList.busy &&
                  !contactList.favouritesIsSelected &&
                  mainPage.isEmpty &&
                  (mainPage.newPhoneToAdd === "") &&
                  !(contactList.filterTerm && contactList.filterTerm !== "")) &&
                  bottomEdge.visible

        Behavior on visible {
            SequentialAnimation {
                 PauseAnimation {
                     duration: !emptyStateScreen.visible ? 500 : 0
                 }
                 PropertyAction {
                     target: emptyStateScreen
                     property: "visible"
                 }
            }
        }

        Icon {
            id: emptyStateIcon
            anchors.horizontalCenter: emptyStateLabel.horizontalCenter
            height: units.gu(5)
            width: units.gu(5)
            opacity: 0.3
            name: "contact"
        }
        Label {
            id: emptyStateLabel
            width: mainPage.width - units.gu(12)
            height: paintedHeight
            text: mainPage.pickMode ?
                      i18n.tr("You have no contacts.") :
                      i18n.tr("Create a new contact by swiping up from the bottom of the screen.")
            color: "#5d5d5d"
            fontSize: "x-large"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    ContactExporter {
        id: contactExporter

        contactModel: contactList.listModel
        exportToDisk: mainPage.pickMode
        onDone: {
            mainPage.pickMode = false
            mainPage.state = "default"
            application.returnVcard(outputFile)
        }

        onContactsFetched: {
            // Share contacts to an application chosen by the user
            if (!mainPage.pickMode) {
                contactExporter.dismissBusyDialog()
                pageStack.addPageToNextColumn(mainPage,
                                              contactShareComponent,
                                              {contactModel: contactExporter.contactModel,
                                               contacts: contacts })
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

    Component {
        id: busyDialogComponent

        Popups.Dialog {
            id: busyDialog

            property alias allowToClose: closeButton.visible
            property alias showActivity: busyIndicator.visible

            title: i18n.tr("Importing...")

            ActivityIndicator {
                id: busyIndicator
                running: visible
                visible: true
            }
            Button {
                id: closeButton
                text: i18n.tr("Close")
                visible: false
                color: UbuntuColors.red
                onClicked: {
                    PopupUtils.close(mainPage._busyDialog)
                    mainPage._busyDialog = null
                }
            }
        }
    }

    Component {
        id: contactShareComponent

        ContactSharePage {
            objectName: "contactSharePage"
        }
    }

    Component.onCompleted: {
        application.elapsed()
        if ((typeof(TEST_DATA) !== "undefined") && (TEST_DATA != "")) {
            mainPage._importingTestData = true
            contactList.listModel.importContacts("file://" + TEST_DATA)
        }

        if (pageStack) {
            pageStack.contactListPage = mainPage
        }
    }

    Component {
        id: editorPageBottomEdge
        ABContactEditorPage {
            backIconName: "down"
            implicitWidth: mainPage.width
            implicitHeight: mainPage.height
            model: contactList.listModel
            contact: ContactsJS.createEmptyContact("", mainPage)
            initialFocusSection: "name"
            enabled: false
        }
    }

    Component {
        id: emptyContact
        ContactsUI.ContactDelegate {
            property Contact contact: Contact {
                Name {
                    firstName: i18n.tr("New contact")
                }
                Avatar {
                    imageUrl: "image://theme/contact"
                }
            }
            width: mainPage.width
        }
    }

    AB.BottomEdge {
        id: bottomEdge
        objectName: "bottomEdge"

        property var incubator

        // FIXME: this is a workaround for the lack of fully asynchronous loading
        // of Pages in AdaptativePageLayout
        function createObjectAsynchronously(url, properties, callback) {
            var component = Qt.createComponent(url, Component.Asynchronous);
            if (component.status == Component.Ready) {
                incubateObject(component, properties, callback);
            } else {
                component.onStatusChanged.connect(function(status) {
                    if (status == Component.Ready) {
                        incubateObject(component, properties, callback);
                    }
                });
            }
        }

        function incubateObject(component, properties, callback) {
            if (component.status == Component.Ready) {
                incubator = component.incubateObject(null,
                                                     properties,
                                                     Qt.Asynchronous);
                incubator.onStatusChanged = function(status) {
                    if (status == Component.Ready) {
                        callback(incubator.object);
                        incubator = null;
                    }
                }
            }
        }

        function loadEditorPage() {
            var newContact = ContactsJS.createEmptyContact("", mainPage);
            createObjectAsynchronously(Qt.resolvedUrl("ABContactEditorPage.qml"),
                                       {model: contactList.listModel,
                                        contact: newContact,
                                        initialFocusSection: "name"},
                                       showContactEditorPage);
        }

        anchors.fill: parent
        contentComponent: pageStack.columns == 1 ? editorPageBottomEdge : emptyContact
        flickable: contactList
        iconName: "contact-new"
        enabled: !contactList.isInSelectionMode
        backGroundEffectEnabled: pageStack.columns === 1

        onOpenBegin: {
            contactList.prepareNewContact = true;
            contactList.positionViewAtBeginning();
            if (pageStack.columns > 1) {
                loadEditorPage();
            }
        }
        onOpenEnd: {
            bottomEdge.visible = false;
            contactList.showNewContact = true;
            if (pageStack.columns <= 1) {
                showContactEditorPage(bottomEdge.content);
            }
        }

        onClicked: {
            bottomEdge.open();
        }
    }

    Connections {
        target: mainPage.contactModel
        onContactsChanged: {
            if (contactIndex) {
                contactList.positionViewAtContact(mainPage.contactIndex)
                mainPage.contactIndex = null
            }
        }
        onImportCompleted: {
            if (mainPage._importingTestData) {
                mainPage._importingTestData = false
                return
            }

            if (error !== ContactModel.ImportNoError) {
                console.error("Fail to import vcard:" + error)
                mainPage._busyDialog.title = i18n.tr("Fail to import contacts!")
                mainPage._busyDialog.allowToClose = true
                mainPage._busyDialog.showActivity = false
            } else {
                var importedIds = ids
                importedIds.concat(importedIdsFilter.ids)
                importedIdsFilter.ids = importedIds
                console.debug("Imported ids:" + importedIds)
                mainPage.state = "vcardImported"

                if (mainPage._busyDialog) {
                    PopupUtils.close(mainPage._busyDialog)
                    mainPage._busyDialog = null
                }
            }
        }
    }

    Connections {
        target: mainPage.contactViewPage
        onEditContact: {
            openEditPage(editPageProperties, mainPage.contactViewPage);
        }
    }

    Connections {
        target: mainPage.contactEditorPage
        onActiveChanged: {
            if (!mainPage.contactEditorPage.active) {
                contactList.prepareNewContact = false;
                contactList.showNewContact = false;
                bottomEdge.visible = true;
                bottomEdge.close();
            }
        }
    }
}
