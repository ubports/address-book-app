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
import Ubuntu.Content 1.3 as ContentHub

import Ubuntu.AddressBook.Base 0.1


Page {
    id: mainPage
    objectName: "contactListPage"

    property var viewPage: null
    property var emptyPage: null
    property var settingsPage: null
    property bool pickMode: false
    property alias contentHubTransfer: contactExporter.activeTransfer
    property bool pickMultipleContacts: false
    property alias contactManager: contactList.manager

    property var _busyDialog: null
    property bool _importingTestData: false
    property bool _creatingContact: false
    property string _newContactId: ""
    // used by tests
    property bool _bottomEdgeEnabled: true

    readonly property string currentViewContactId: viewPage && viewPage.contact ? viewPage.contact.contactId : ""
    readonly property bool isEmpty: (contactList.count === 0)
    readonly property bool allowToQuit: (application.callbackApplication.length > 0)
    readonly property var contactModel: contactList.listModel ? contactList.listModel : null
    readonly property bool searching: state === "searching"
    readonly property string headerTitle: pageHeader.title
    readonly property alias contactListItem: contactList

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
            pageStack.addPageToNextColumn(mainPage,
                                          Qt.resolvedUrl("ABContactEditorPage.qml"),
                                          { model: mainPage.contactModel,
                                            contact: newContact,
                                            backIconName: 'back'
                                           })
        }
    }

    function clearViewPage()
    {
        viewPage = null
    }

    function clearSettingsPage()
    {
        settingsPage = null
    }

    function hasChildPage()
    {
        return (settingsPage != null);
    }

    function openViewPage(viewPageProperties)
    {
        if (currentViewContactId === viewPageProperties.contact.contactId) {
            return
        }

        if (viewPage) {
            viewPage.Component.onDestruction.disconnect(clearViewPage)
        }

        pageStack.removePages(mainPage)
        viewPage = null

        viewPage = pageStack.addFileToNextColumnSync(mainPage, Qt.resolvedUrl("ABContactViewPage.qml"), viewPageProperties)
        viewPage.Component.onDestruction.connect(clearViewPage)
    }

    function showContact(contact)
    {
        var currentContact = contactList.currentIndex != -1 ? contactList.listModel.contacts[contactList.currentIndex] : null
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

    function showEmptyPage(openBottomEdge)
    {
        if (pageStack.columns === 1)
            return

        var newEmptyPage = null
        if (!mainPage.emptyPage) {
            contactList.currentIndex = -1
            pageStack.removePages(mainPage)

            if (pageStack.columns) {
                newEmptyPage  = pageStack.addFileToNextColumnSync(pageStack.primaryPage,
                                                               Qt.resolvedUrl("ABMultiColumnEmptyState.qml"),
                                                               { 'headerTitle': "",
                                                                 'pageStack': mainPage.pageStack,
                                                                 'model': mainPage.contactModel })
                newEmptyPage.Component.onDestruction.connect(function() {
                    mainPage.emptyPage = null
                })

            }
        } else {
            newEmptyPage = mainPage.emptyPage
        }

        if (openBottomEdge) {
            newEmptyPage.commitBottomEdge()
        }

        mainPage.emptyPage = newEmptyPage

    }

    function showSettingsPage()
    {
        if (settingsPage) {
            settingsPage.Component.onDestruction.disconnect(clearSettingsPage)
        }

        pageStack.removePages(mainPage)
        viewPage = null
        settingsPage = null
        emptyPage = null


        settingsPage = pageStack.addFileToNextColumnSync(mainPage,
                                                         Qt.resolvedUrl("./Settings/SettingsPage.qml"),
                                                        {"contactListModel": contactList.listModel})
        settingsPage.Component.onDestruction.connect(clearSettingsPage)
    }

    function showContactWithId(contactId)
    {
        openViewPage({model: contactList.listModel,
                      contactId: contactId});
    }

    function importContact(urls)
    {
        mainPage._busyDialog = PopupUtils.open(Qt.resolvedUrl("./BusyImportingDialog.qml"), mainPage)
        mainPage._busyDialog.destruction.connect(function() {mainPage._busyDialog = null})

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

    function onNewContactSaved(contact) {
        _newContactId = contact.contactId
    }

    // Delay contact fetch for some msecs (check 'fetchNewContactTimer')
    function delayFetchContact()
    {
        fetchNewContactTimer.restart()
    }

    function fetchContact()
    {
        if (pageStack.columns > 1 && !contactList.showNewContact && !pageStack.bottomEdgeOpened) {
            var currentContact = null
            if (contactList.currentIndex >= 0)
                currentContact = contactList.listModel.contacts[contactList.currentIndex]

            if (!currentContact) {
                showEmptyPage()
                return
            } else if (currentContact && (mainPage.currentViewContactId === currentContact.contactId)) {
                return
            }

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
                           !pageStack.bottomEdgeOpened
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
        showNewContact: (pageStack.columns > 1) && pageStack.bottomEdgeOpened
        highlightSelected: !showNewContact && pageStack.hasKeyboard && (mainPage._newContactId === "")
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

        onCountChanged: {
            if (mainPage.state === "searching") {
                currentIndex = 0
            }
            mainPage.delayFetchContact()
        }

        onCurrentIndexChanged: {
            mainPage.delayFetchContact()
        }

        onOnlineAccountFinished: {
            if (mainPage.allowToQuit) {
                application.goBackToSourceApp()
            }
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
            if (pageStack.bottomEdgeOpened) {
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

            property list<QtObject> trailingActions: [
                Action {
                    text: i18n.tr("Search")
                    iconName: "search"
                    visible: !mainPage.isEmpty
                    enabled: visible && (mainPage.state === "default")
                    shortcut: "Ctrl+F"
                    onTriggered: {
                        if (viewPage) {
                            viewPage.cancelEdit()
                        }


                        if (pageStack.bottomEdgeOpened) {
                            pageStack.closeBottomEdge()
                        } else {
                            showEmptyPage(false)
                        }
                        mainPage.state = "searching"
                        contactList.showAllContacts()
                        searchField.forceActiveFocus()
                    }
                },
                Action {
                    iconName: "contact-new"
                    enabled: visible && !pageStack.bottomEdgeOpened
                    visible: (pageStack.columns > 1)
                    shortcut: "Ctrl+N"
                    onTriggered: {
                        if (!pageStack.bottomEdgeOpened && (viewPage || emptyPage)) {
                            pageStack._bottomEdge.commit()
                        } else {
                            showEmptyPage(true)
                        }
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
                    onTriggered: mainPage.showSettingsPage()
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
                    enabled: (mainPage.state === "searching") && mainPage.active
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
                text: ""
            }
        },
        State {
            id: selectionState
            name: "selection"

            property list<QtObject> leadingActions: [
                Action {
                    objectName: "cancel"
                    name: "cancel"
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

                        var dialog = PopupUtils.open(Qt.resolvedUrl("RemoveContactsDialog.qml"),
                                                     null,
                                                     {"contactListModel": contactList.listModel})
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
                    objectName: "cancel"
                    name: "cancel"
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
                !pageStack.bottomEdgeOpened
    }

    ABEmptyState {
        id: emptyStateScreen

        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: contactList.headerItem ? contactList.headerItem.height / 2 : 0
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
                                              Qt.resolvedUrl("ContactShare/ContactSharePage.qml"),
                                              {contactModel: contactExporter.contactModel,
                                               contacts: contacts })
            }
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
            mainPage.delayFetchContact()
        }
    }

    Loader {
        id: bottomEdgeLoader

        enabled: false
        active: true
        asynchronous: true
        Component.onCompleted: {
            if (mainPage._bottomEdgeEnabled) {
                setSource(Qt.resolvedUrl("ABNewContactBottomEdge.qml"),
                                         {"parent": mainPage,
                                          "modelToEdit": Qt.binding(function () {return mainPage.contactModel}),
                                          "hint.flickable": Qt.binding(function () {return contactList.view}),
                                          "pageStack": Qt.binding(function () {return mainPage.pageStack}),
                                          "enabled": Qt.binding(function () {return mainPage.active}),
                                          "hintVisible": Qt.binding(function () {return mainPage.pageStack.columns === 1}),
                                          "visible": Qt.binding(function () {return mainPage.pageStack.columns === 1})
                                         })
            }
        }
    }

    Binding {
        target: pageStack
        property: '_bottomEdge'
        value: bottomEdgeLoader.item
        when: (bottomEdgeLoader.status === Loader.Ready) &&
              (pageStack.columns === 1) &&
              bottomEdgeLoader.enabled
    }

    Action {
        iconName: "contact-new"
        enabled: mainPage.active && !mainPage.bottomEdgeOpened
        shortcut: "Ctrl+N"
        onTriggered: {
            bottomEdgeLoader.item.commit()
        }
    }

    Connections {
        target: mainPage.contactModel

        onContactsChanged: {
            // if is a new contact show it
            if (mainPage._newContactId != "") {
                contactList.positionViewAtContactId(mainPage._newContactId)
                mainPage._newContactId = ""
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
        target: pageStack
        onBottomEdgeOpenedChanged: {
            if (pageStack.bottomEdgeOpened) {
                if (mainPage.state !== "default") {
                    mainPage.head.sections.selectedIndex = 0
                    mainPage.state = "default"
                }
            } else {
                if (mainPage._creatingContact === "") {
                    if (contactList.currentIndex === -1)
                        contactList.currentIndex = 0
                    mainPage.delayFetchContact()
                }

                if (mainPage.status === "default") {
                    contactList.forceActiveFocus()
                }
            }
        }
    }
}
