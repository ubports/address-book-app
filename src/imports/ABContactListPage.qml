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

    property var viewPage: null
    property bool pickMode: false
    property alias contentHubTransfer: contactExporter.activeTransfer
    property bool pickMultipleContacts: false
    property QtObject contactIndex: null
    property alias contactManager: contactList.manager

    property var _busyDialog: null
    property bool _importingTestData: false
    property bool _creatingContact: false

    readonly property string currentViewContactId: viewPage && viewPage.contact ? viewPage.contact.contactId : ""
    readonly property bool isEmpty: (contactList.count === 0)
    readonly property bool allowToQuit: (application.callbackApplication.length > 0)
    readonly property var contactModel: contactList.listModel ? contactList.listModel : null
    readonly property bool searching: state === "searching"

    // this function is used to reset the contact list page to the default state if it was called
    // from the uri. For example when called to add a new contact
    function returnToNormalState()
    {
        application.callbackApplication = ""
    }

    function createContactWithPhoneNumber(phoneNumber)
    {
        var newContact = ContactsJS.createEmptyContact(phoneNumber, mainPage);
        if (bottomEdgeLoader.status == Loader.Ready) {
            bottomEdgeLoader.editContact(newContact)
        } else {
            contactList.currentIndex = -1
            var incubator = pageStack.addPageToNextColumn(mainPage,
                                                         Qt.resolvedUrl("ABContactEditorPage.qml"),
                                                        { model: mainPage.contactModel,
                                                          contact: newContact,
                                                          backIconName: 'back',
                                                          enabled: false
                                                          })
        }
    }

    function openViewPage(viewPageProperties) {
        var component = Qt.createComponent(Qt.resolvedUrl("ABContactViewPage.qml"))
        var incubator = pageStack.addPageToNextColumn(mainPage, component, viewPageProperties)
        if (incubator && (incubator.status === Component.Loading)) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready)
                    mainPage.viewPage =  incubator.object
            }
        } else if (incubator && incubator.status ===- Component.Ready) {
            mainPage.viewPage =  incubator.object
        } else {
            mainPage.viewPage =  null
        }
    }

    function showContact(contact)
    {
        var currentContact = contactList.listModel.contacts[contactList.currentIndex]
        if (currentContact && (mainPage.currentViewContactId === currentContact.contactId)) {
            // contact view already opened with this contact
            return
        }

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
        if ((state !== "searching") &&
            (state !== "vcardImported")) {
            mainPage.state = "default"
        }

        contactIndex = contact
        // this means a new contact was created
        if (mainPage.allowToQuit) {
            application.goBackToSourceApp()
        }
    }


    function onNewContactSaved(contact) {
        _creatingContact = true
        moveListToContact(contact)
        if (pageStack.columns > 1) {
            showContact(contact);
        }
    }

    // Delay contact fetch for some msecs (check 'fetchNewContactTimer')
    function delayFetchContact()
    {
        fetchNewContactTimer.restart()
    }

    function fetchContact()
    {
        if ((contactList.currentIndex >= 0) && (pageStack.columns > 1)) {
            var currentContact = contactList.listModel.contacts[contactList.currentIndex]
            if (!currentContact) {
                var component = Qt.createComponent(Qt.resolvedUrl("ABMultiColumnEmptyState.qml"))
                var searching = contactList.filterTerm !== ""
                pageStack.addPageToNextColumn(mainPage, component,
                                              { headerTitle: searching ? i18n.tr("No contact found") : i18n.tr("No contacts") })
                return
            }
            if (currentContact && (mainPage.currentViewContactId === currentContact.contactId))
                return

            contactList.view._fetchContact(contactList.currentIndex, currentContact)
        }
    }

    header: PageHeader {
        id: pageHeader

        property alias leadingActions: leadingBar.actions
        property alias trailingActions: trailingBar.actions
        property alias sectionsModel: sections.model

        title: i18n.tr("Contacts")
        //flickable: contactList.view
        trailingActionBar {
            id: trailingBar
        }
        leadingActionBar {
            id: leadingBar
        }
        extension: Sections {
            id: sections
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                bottom: parent.bottom
            }
            onSelectedIndexChanged: {
                switch (selectedIndex) {
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
    }

    // This timer is to avoid fetch unecessary contact if the user select the contacts too fast
    // while navigating on contact list with keyboard
    Timer {
        id: fetchNewContactTimer

        interval: 300
        repeat: false
        onTriggered: mainPage.fetchContact()
    }

    title: i18n.tr("Contacts")
    flickable: null

    ContactsUI.ContactListView {
        id: contactList
        objectName: "contactListView"

        focus: true
        showImportOptions: !mainPage.pickMode &&
                           pageStack.bottomEdge &&
                           (pageStack.bottomEdge.status === BottomEdge.Hidden)
        anchors {
            top: parent.top
            topMargin: pageHeader.height
            left: parent.left
            bottom: keyboard.top
            right: parent.right
        }
        currentIndex: -1
        filterTerm: searchField.text
        multiSelectionEnabled: true
        multipleSelection: (mainPage.pickMode && mainPage.pickMultipleContacts) || !mainPage.pickMode
        showNewContact: (pageStack.columns > 1) && pageStack.bottomEdge && (pageStack.bottomEdge.status === BottomEdge.Committed)
        highlightSelected: pageStack.hasKeyboard && !mainPage._creatingContact
        onAddContactClicked: mainPage.createContactWithPhoneNumber(label)
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
                (contactList.currentIndex === -1) &&
                (pageStack.bottomEdge.status === BottomEdge.Hidden)) {
                contactList.currentIndex = 0
            }
            mainPage.delayFetchContact()
        }

        onCurrentIndexChanged: {
            if (!mainPage.contactIndex)
                mainPage.delayFetchContact()
        }

        Keys.onReturnPressed: {
            var currentContact = contactList.listModel.contacts[contactList.currentIndex]
            if (mainPage.currentViewContactId === currentContact.contactId)
                return

            contactList.view._fetchContact(contactList.currentIndex, currentContact)
        }

        //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
        //because of that we need this
        Keys.onRightPressed: {
            // only move focus away when in edit mode
            if (pageStack.bottomEdge.status === BottomEdge.Committed) {
                var next = pageStack._nextItemInFocusChain(view, true)
                if (next === searchField) {
                    pageStack._nextItemInFocusChain(next, true)
                }
            }
        }
        Keys.onTabPressed: {
            var next = pageStack._nextItemInFocusChain(view, true)
            if (next === searchField) {
                pageStack._nextItemInFocusChain(next, true)
            }
        }
    }

    TextField {
        id: searchField

        //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
        //because of that we need this
        readonly property bool _allowFocus: true

        anchors {
            top: parent ? parent.top : undefined
            left: parent ? parent.left : undefined
            right: parent ? parent.right : undefined
            margins: units.gu(1)
            rightMargin: units.gu(2)
        }

        visible: false
        inputMethodHints: Qt.ImhNoPredictiveText
        placeholderText: i18n.tr("Search...")
        onVisibleChanged: {
            if (visible) {
                if (activeFocus) {
                    Qt.inputMethod.show()
                } else {
                    searchField.forceActiveFocus()
                }
            }
        }

        Keys.onTabPressed: contactList.forceActiveFocus()
        Keys.onDownPressed: contactList.forceActiveFocus()
    }

    state: "default"
    states: [
        State {
            id: defaultState
            name: "default"

            property list<QtObject> leadingActions: [
                Action {
                    visible: mainPage.allowToQuit
                    iconName: "back"
                    text: i18n.tr("Quit")
                    onTriggered: {
                        application.goBackToSourceApp()
                        mainPage.returnToNormalState()
                    }
                }
            ]

            property list<QtObject> trailingActions:  [
                Action {
                    text: i18n.tr("Search")
                    iconName: "search"
                    visible: !mainPage.isEmpty
                    enabled: visible && (mainPage.state === "default")
                    shortcut: "Ctrl+F"
                    onTriggered: {
                        mainPage.state = "searching"
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
                    onTriggered:{
                        var incubator = pageStack.addPageToNextColumn(mainPage,
                                                                      Qt.resolvedUrl("./Settings/SettingsPage.qml"),
                                                                     {"contactListModel": contactList.listModel})
                        incubator.onStatusChanged = function(status) {
                            if (status === Component.Ready) {
                                incubator.object.onActiveChanged.connect(function(active) {
                                    if (!incubator.object.active) {
                                        mainPage.delayFetchContact()
                                        contactList.forceActiveFocus()
                                    }
                                })
                            }
                        }
                    }
                }
            ]

            PropertyChanges {
                target: pageHeader

                // TRANSLATORS: this refers to all contacts
                sectionsModel:  [i18n.tr("All"), i18n.tr("Favorites")]
                leadingActions: defaultState.leadingActions
                trailingActions: defaultState.trailingActions
            }
            PropertyChanges {
                target: searchField
                text: ""
            }
            PropertyChanges {
                target: bottomEdgeLoader
                enabled: true
            }
        },
        State {
            id: searchingState
            name: "searching"

            property list<QtObject> leadingActions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Cancel")
                    enabled: (mainPage.state === "searching") &&
                             mainPage.active &&
                             (!pageStack.bottomEdge ||
                              (pageStack.bottomEdge && (pageStack.bottomEdge.status === BottomEdge.Hidden))) &&
                             ((pageStack.columns === 1) ||
                              (mainPage.viewPage && mainPage.viewPage.active))
                    shortcut:"Esc"
                    onTriggered: {
                        mainPage.head.sections.selectedIndex = 0
                        mainPage.state = "default"
                        contactList.forceActiveFocus()
                    }
                }
            ]

            PropertyChanges {
                target: pageHeader

                contents: searchField
                leadingActions: searchingState.leadingActions

            }

            PropertyChanges {
                target: bottomEdgeLoader
                enabled: false
            }

            PropertyChanges {
                target: searchField
                visible: true
                focus: true
                text: ""
            }
        },
        State {
            id: selectionState
            name: "selection"

            property list<QtObject> leadingActions: [
                Action {
                    text: i18n.tr("Cancel selection")
                    iconName: "back"
                    enabled: mainPage.state === "selection"
                    onTriggered: contactList.cancelSelection()
                    shortcut: "Esc"
                }
            ]

            property list<QtObject> trailingActions: [
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
                target: pageHeader

                leadingActions: selectionState.leadingActions
                trailingActions: selectionState.trailingActions
            }

            PropertyChanges {
                target: bottomEdgeLoader
                enabled: false
            }
        },
        State {
            id: vcardImportedState
            name: "vcardImported"

            property list<QtObject> leadingActions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Back")
                    onTriggered: {
                        contactList.forceActiveFocus()
                        mainPage.state = "default"
                        importedIdsFilter.ids = []
                    }
                }
            ]

            PropertyChanges {
                target: pageHeader

                leadingActions: vcardImportedState.leadingActions
                title: i18n.tr("Imported contacts")
            }

            PropertyChanges {
                target: bottomEdgeLoader
                enabled: false
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
        } else if (active) {
            contactList.forceActiveFocus()
        }
    }

    IdFilter {
        id: importedIdsFilter
    }

    KeyboardRectangle {
        id: keyboard
        active: mainPage.active &&
                (pageStack.bottomEdge && (pageStack.bottomEdge.status === BottomEdge.Hidden))
    }

    ABEmptyState {
        id: emptyStateScreen

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: units.gu(6)
            rightMargin: units.gu(6)
        }

        height: childrenRect.height
        visible: ((pageStack.columns === 1) &&
                  !contactList.busy &&
                  !contactList.favouritesIsSelected &&
                  mainPage.isEmpty &&
                  !(contactList.filterTerm && contactList.filterTerm !== ""))
        text: mainPage.pickMode ?
                  i18n.tr("You have no contacts.") :
                  i18n.tr("Create a new contact by swiping up from the bottom of the screen.")
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

    Loader {
        id: bottomEdgeLoader

        enabled: false
        active: (pageStack.columns === 1) && bottomEdgeLoader.enabled
        asynchronous: true
        sourceComponent: ABNewContactBottomEdge {
            parent: mainPage
            modelToEdit: mainPage.contactModel
            hint.flickable: contactList.view
            pageStack: mainPage.pageStack
            enabled: mainPage.active
        }
    }

    Binding {
        target: pageStack
        property: 'bottomEdge'
        value: bottomEdgeLoader.item
        when: bottomEdgeLoader.status == Loader.Ready
    }

    Connections {
        target: mainPage.contactModel

        onContactsChanged: {
            if (contactIndex) {
                contactList.positionViewAtContact(mainPage.contactIndex)
                mainPage.contactIndex = null
                // at this point the operation has finished already
                mainPage._creatingContact = false
                fetchNewContactTimer.restart()
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
        target: pageStack.bottomEdge
        onCommitCompleted: {
            if (mainPage.state !== "default") {
                mainPage.head.sections.selectedIndex = 0
                mainPage.state = "default"
            }
        }
        onCollapseCompleted: {
            if (!mainPage._creatingContact) {
                if (contactList.currentIndex === -1)
                    contactList.currentIndex = 0
                mainPage.delayFetchContact()
            }
        }
    }
}
