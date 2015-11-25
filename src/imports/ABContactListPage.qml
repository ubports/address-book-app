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
        var currentContact = contactList.listModel.contacts[contactList.currentIndex]
        if (contactViewPage && contactViewPage.contact && (contactViewPage.contact.contactId === currentContact.contactId)) {
            console.debug("Skip show contact")
            return
        }

        // go back to normal state if not searching
        if (state !== "searching") {
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
        // skipt it if searching
        if (state === "searching") {
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

        focus: true
        showImportOptions:  !mainPage.pickMode &&
                            mainPage.newPhoneToAdd === "" &&
                            (!mainPage.contactEditorPage || !mainPage.contactEditorPage.active)
        anchors {
            top: parent.top
            left: parent.left
            bottom: keyboard.top
            right: parent.right
        }
        currentIndex: 0
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
        onActiveFocusChanged: {
            if (activeFocus && (contactList.currentIndex === -1)) {
                contactList.currentIndex = 0
            }
        }
        onCountChanged: {
            if (mainPage.active &&
                (pageStack.columns > 1) &&
                (contactList.currentIndex === -1)) {
                contactList.currentIndex = 0
            }
            fetchNewContactTimer.restart()
        }
        onCurrentIndexChanged: fetchNewContactTimer.restart()

        //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
        //because of that we need this
        Keys.onRightPressed: {
            var next = pageStack._nextItemInFocusChain(view, true)
            if (next === searchField) {
                pageStack._nextItemInFocusChain(next, true)
            }
        }
    }

    Timer {
        id: fetchNewContactTimer

        interval: 0
        repeat: false
        onTriggered: {
            if ((contactList.currentIndex >= 0) && (pageStack.columns > 1)) {
                var currentContact = contactList.listModel.contacts[contactList.currentIndex]
                if (contactViewPage && contactViewPage.contact && (contactViewPage.contact.contactId === currentContact.contactId))
                    return

                contactList.view._fetchContact(contactList.currentIndex, currentContact)
            }
        }
    }

    TextField {
        id: searchField

        //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
        //because of that we need this
        readonly property bool _allowFocus: true

        anchors {
            left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
        }

        visible: false
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search...")
        onVisibleChanged: {
            if (visible) {
                if (activeFocus) {
                    Qt.imputMethod.show()
                } else {
                    searchField.forceActiveFocus()
                }
            }
        }

        Keys.onTabPressed: contactList.forceActiveFocus()
        Keys.onDownPressed: contactList.forceActiveFocus()
        Keys.onRightPressed: pageStack._nextItemInFocusChain(searchField, true)
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
                    shortcut: mainPage.state === "default" ? "Ctrl+F" : ""
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
            PropertyChanges {
                target: bottomEdge
                enabled: true
            }
        },
        PageHeadState {
            id: searchingState

            name: "searching"
            backAction: Action {
                iconName: "back"
                text: i18n.tr("Cancel")
                shortcut: mainPage.state === "searching" && !mainPage.contactEditorPage ? "Esc" : ""
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
                shortcut: mainPage.state === "selection" ? "Esc" : ""
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
        }
    ]

    onActiveChanged: {
        if (active && contactList.showAddNewButton) {
            contactList.positionViewAtBeginning()
        }

        if (active && (state === "searching")) {
            searchField.forceActiveFocus()
        } else if (active) {
            contactList.forceActiveFocus()
        }
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

    Connections {
        target: mainPage.contactModel
        onContactsChanged: {
            if (contactIndex) {
                contactList.positionViewAtContact(mainPage.contactIndex)
                mainPage.contactIndex = null
            }
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
        id: contactShareComponent

        ContactSharePage {
            objectName: "contactSharePage"
        }
    }

    Component.onCompleted: {
        application.elapsed()
        if ((typeof(TEST_DATA) !== "undefined") && (TEST_DATA !== "")) {
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

    BottomEdge {
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
        backGroundEffectEnabled: pageStack.columns === 1

        onOpenBegin: {
            contactList.prepareNewContact = true;
            contactList.positionViewAtBeginning();
            if (pageStack.columns > 1) {
                loadEditorPage();
            }
        }
        onOpenEnd: {
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
        target: mainPage.contactViewPage
        onEditContact: {
            openEditPage(editPageProperties, mainPage.contactViewPage);
        }
        onActiveChanged: {
            if (!mainPage.contactViewPage.active) {
                mainPage.contactViewPage = null
            }
        }
    }

    Connections {
        target: mainPage.contactEditorPage
        onActiveChanged: {
            if (!mainPage.contactEditorPage.active) {
                contactList.prepareNewContact = false;
                contactList.showNewContact = false;
                bottomEdge.close();
                mainPage.contactEditorPage = null
                contactList.forceActiveFocus()
                bottomEdge.enabled = true
            } else {
                bottomEdge.enabled = false
            }
        }
    }
}
