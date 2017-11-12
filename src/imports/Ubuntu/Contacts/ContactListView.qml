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
import Ubuntu.Components.Popups 1.3
import Ubuntu.Contacts 0.1 as Contacts
import Buteo 0.1

/*!
    \qmltype ContactListView
    \inqmlmodule Ubuntu.Contacts 0.1
    \ingroup ubuntu
    \brief The ContactListView provides the contact list view integrated with the Favorite List View

    The ContactListView is based on ContactSimpleListView and provide a easy way to show the contact
    list view with all default visuals defined by Ubuntu system.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        ContactListView {
            anchors.fill: parent
            onContactClicked: console.debug("Contact ID:" + contact.contactId)
        }
    \endqml
*/
FocusScope {
    id: root

    readonly property alias view: view
    readonly property alias count: view.count

    property var header: []

    /*!
      \qmlproperty string contactStringFilter

      This property holds a string that will be used to filter contacts on the list
      By default this is set to empty
    */
    property alias filterTerm: contactsModel.filterTerm
    /*!
      \qmlproperty Filter filter

      This property holds the filter instance used by the contact model.

      \sa Filter
    */
    property alias filter: contactsModel.externalFilter
    /*!
      \qmlproperty bool showAvatar

      This property holds if the contact avatar will appear on the list or not.
      By default this is set to true.
    */
    property alias showAvatar: view.showAvatar
    /*!
      \qmlproperty list<SortOrder> sortOrders

      This property holds a list of sort orders used by the contacts model.
      \sa SortOrder
    */
    property alias sortOrders: view.sortOrders
    /*!
      \qmlproperty FetchHint fetchHint

      This property holds the fetch hint instance used by the contact model.

      \sa FetchHint
    */
    property alias fetchHint: view.fetchHint
    /*!
      \qmlproperty bool multiSelectionEnabled

      This property holds if the multi selection mode is enabled or not
      By default this is set to false
    */
    property alias multiSelectionEnabled: view.multiSelectionEnabled
    /*!
      \qmlproperty string defaultAvatarImage

      This property holds the default image url to be used when the current contact does
      not contains a photo
    */
    property alias defaultAvatarImageUrl: view.defaultAvatarImageUrl
    /*!
      \qmlproperty bool loading

      This property holds when the model still loading new contacts
    */
    readonly property alias loading: view.loading
    /*!
      \qmlproperty int currentIndex

      This property holds the current active item index
    */
    property alias currentIndex: view.currentIndex
    /*!
      \qmlproperty bool showSections

      This property holds if the listview will show or not the section headers
      By default this is set to true
    */
    property alias showSections: view.showSections
    /*!
      \qmlproperty string manager

      This property holds the manager uri of the contact backend engine.
      By default this is set to "galera"
    */
    property alias manager: view.manager
    /*!
      \qmlproperty bool fastScrolling

      This property holds if the listview is in fast scroll mode or not
    */
    property alias fastScrolling: fastScroll.fastScrolling
    /*!
      \qmlproperty Action leftSideAction

      This property holds the available actions when swipe the contact item from left to right
    */
    property alias leftSideAction: view.leftSideAction
    /*!
      \qmlproperty list<Action> rightSideActions

      This property holds the available actions when swipe the contact item from right to left
    */
    property alias rightSideActions: view.rightSideActions
    /*!
      \qmlproperty model selectedItems

      This property holds the list of selected items
    */
    readonly property alias selectedItems: view.selectedItems
    /*!
      \qmlproperty bool multipleSelection

      This property holds if the selection will accept multiple items or single items
    */
    property alias multipleSelection: view.multipleSelection
    /*!
      \qmlproperty model listModel

      This property holds the model providing data for the list.
    */
    property alias listModel: view.listModel
    /*!
      \qmlproperty Component listDelegate

      The delegate provides a template defining each item instantiated by the view.
    */
    property alias listDelegate: view.listDelegate
    /*!
      \qmlproperty bool autoUpdate

       This property indicates whether or not the contact model should be updated automatically, default value is true.
    */
    property alias autoUpdate: contactsModel.autoUpdate

    /*!
      \qmlproperty bool autoHideKeyboard

       This property indicates if the OSK should disapear when the list starts to  flick.
    */
    property bool autoHideKeyboard: true

    /*!
      \qmlproperty bool isInSelectionMode

      This property holds a list with the index of selected items
    */
    readonly property alias isInSelectionMode: view.isInSelectionMode
    /*!
      \qmlproperty bool showImportOptions

      This property holds if the import options should be visible on the list
    */
    property bool showImportOptions: false    
    /*!
      \qmlproperty bool showImportFromAccountOption

      This property holds if the import from account option should be visible on the list
    */
    property bool showImportFromAccountOption: buteoSync.serviceAvailable

    /*!
      \qmlproperty bool showAddNewButton

      This property holds if the add new button should be visible or not
    */
    property bool showAddNewButton: false
    /*!
      \qmlproperty bool showNewContact

      This property holds if a draft new contact should be visible or not
    */
    property bool showNewContact: false
    /*!
      \qmlproperty bool syncing

      This property holds if the list is running a sync with online accounts or not
    */
    readonly property bool syncing: buteoSync.syncing || Contacts.Contacts.updateIsRunning
    /*!
      \qmlproperty bool syncEnabled

      This property holds if there is online account to sync or not
    */
    // we are using 'buteoSync.visibleSyncProfiles because' it is a property
    // and will re-check if the property changes.
    // Using only '(buteoSync.syncProfilesByCategory("contacts").length > 0)'
    // the value will be checked only on app startup
    readonly property bool syncEnabled: (buteoSync.profilesCount > 0) &&
                                        (buteoSync.syncProfilesByCategory("contacts").length > 0)

    property alias headerItem: view.headerItem
    /*!
      \qmlproperty bool busy

      This property holds if the list is busy or not
    */
    property alias busy: indicator.isBusy
    /*!
      \qmlproperty bool showBusyIndicator

      This property holds if the busy indicator should became visible
    */
    property bool showBusyIndicator: true
    /*!
      \qmlproperty real verticalVelocity

      This property holds the vertical velocity of the list
    */
    readonly property real verticalVelocity: view.verticalVelocity

    property alias highlightSelected: view.highlightSelected

    property var _busyDialog: null

    //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
    //because of that we need this
    property bool _allowFocus: true


    /*!
      This property holds the application id used to request access to online accounts
    */
    property string onlineAccountApplicationId: "address-book-app"

    /*!
      This handler is called when the selection mode is finished without be canceled
    */
    signal selectionDone(var items)
    /*!
      This handler is called when the selection mode is canceled
    */
    signal selectionCanceled()
    /*!
      This handler is called when any error occurs in the contact model
    */
    signal error(string message)
    /*!
      This handler is called when a unknown contact is clicked, the label contains the phone number
    */
    signal addContactClicked(string label)
    /*!
      This handler is called when the contact delegate disapear (height === 0) caused by the function call makeDisappear
    */
    signal contactDisappeared(QtObject contact)
    /*!
      This handler is called when the button add new contact is clicked
    */
    signal addNewContactClicked()
    /*!
      This handler is called when any contact in the list receives a click
    */
    signal contactClicked(QtObject contact)
    /*!
      This handler is called when online account operation finish
    */
    signal onlineAccountFinished()

    function startSelection()
    {
        view.startSelection()
    }
    function isSelected(item)
    {
        return view.isSelected(item)
    }
    function selectItem(item)
    {
        return view.selectItem(item)
    }
    function deselectItem(item)
    {
        return view.deselectItem(item)
    }
    function endSelection()
    {
        view.endSelection()
    }
    function cancelSelection()
    {
        view.cancelSelection()
    }
    function clearSelection()
    {
        view.clearSelection()
    }
    function selectAll()
    {
        view.selectAll()
    }
    function returnToBounds()
    {
        view.returnToBounds()
    }
    function positionViewAtContact(contact)
    {
        view.positionViewAtContact(contact)
    }
    function positionViewAtContactId(contactId)
    {
        view.positionViewAtContactId(contactId)
    }
    function positionViewAtBeginning()
    {
        moveToBegining.restart()
    }
    function changeFilter(newFilter)
    {
        contactsModel.changeFilter(newFilter)
    }
    function reset()
    {
        if (view.favouritesIsSelected) {
            showAllContacts()
        } else {
            positionViewAtBeginning()
        }
    }
    function showFavoritesContacts()
    {
        //WORKAROUND: clear the model before start populate it with the new contacts
        //otherwise the model will wait for all contacts before show any new contact
        if (!view.favouritesIsSelected) {
            root.changeFilter(root.filter)
            view.favouritesIsSelected = true
        }
    }
    function showAllContacts()
    {
        if (view.favouritesIsSelected) {
            root.changeFilter(root.filter)
            view.favouritesIsSelected = false
        }
    }

    /*!
      Causes the list to update
      \l autoUpdate
    */
    function update()
    {
        contactsModel.update()
    }

    /*!
      Start an online account sync opration
    */
    function sync()
    {
       buteoSync.startSyncByCategory("contacts")
    }

    /*!
      start an online account creation
    */
    function createOnlineAccount(provider)
    {
        onlineAccountHelper.start(provider)
    }

    focus: true

    ContactSimpleListView {
        id: view

        property bool showFavourites: true
        property alias favouritesIsSelected: contactsModel.onlyFavorites
        property bool contactsLoaded: false

        function getSectionText(index) {
            var tag = listModel.contacts[index].tag.tag
            if (tag == "")
                return "#"
            else
                return tag
        }

        // if the favorite header became invisible we should move back to all contacts.
        onShowFavouritesChanged: {
            if (!showFavourites && view.favouritesIsSelected) {
                root.changeFilter(root.filter)
                view.favouritesIsSelected = false
            }
        }

        onFlickStarted: {
            if (autoHideKeyboard)
                forceActiveFocus()
        }
        anchors.fill: parent


        // WORKAROUND: The SDK header causes the contactY to move to a wrong postion
        // calling the positionViewAtBeginning after the list created fix that
        Timer {
            id: moveToBegining

            interval: 100
            running: false
            repeat: false
            onTriggered: view.positionViewAtBeginning()
        }

        header: Column {
            anchors {
                left: parent.left
                right: parent.right
            }

            // top margin
            Item {
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(0.5)
            }

            Binding {
                target: view
                property: 'currentIndex'
                value: -1
                when: root.showNewContact
            }

            // AddNewButton
            ContactListButtonDelegate {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                objectName: "addNewButton"

                iconSource: "image://theme/add"
                // TRANSLATORS: this refers to a new contact
                labelText: i18n.dtr("address-book-app", "+ Create New")
                onClicked: root.addNewContactClicked()
                visible: root.showAddNewButton
            }

            ContactDelegate {
                property var contact: Contact {
                    Name {
                        firstName: i18n.tr("New contact")
                    }
                    Avatar {
                        imageUrl: "image://theme/contact"
                    }
                }
                selected: pageStack.hasKeyboard
                visible: root.showNewContact
                height: root.showNewContact ? defaultHeight : 0
                onHeightChanged: {
                    if (visible)
                        view.positionViewAtBeginning()
                }
                Behavior on height {UbuntuNumberAnimation {}}
            }

            Column {
                id: importFromButtons
                objectName: "importFromButtons"

                readonly property bool isSearching: (root.filterTerm && root.filterTerm !== "")

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: visible ? childrenRect.height : 0

                visible: root.showImportOptions &&
                         !indicator.visible &&
                         (root.count === 0) &&
                         !view.favouritesIsSelected &&
                         !isSearching

                // avoid show the button while the list still loading contacts
                Behavior on visible {
                    SequentialAnimation {
                         PauseAnimation {
                             duration: !importFromButtons.visible ? 500 : 0
                         }
                         PropertyAction {
                             target: importFromButtons
                             property: "visible"
                         }
                    }
                }

                Repeater {
                    model: onlineAccountHelper.status === Loader.Ready ? onlineAccountHelper.item.providerModel : []
                    ContactListButtonDelegate {
                        objectName: "%1.importFromOnlineAccountButton.%2".arg(root.objectName).arg(model.providerId)

                        expandIcon: true
                        iconSource: model.iconName.indexOf("/") === 0 ?
                            model.iconName : "image://theme/" + model.iconName
                        labelText: i18n.dtr("address-book-app", "Import contacts from %1").arg(model.displayName)
                        onClicked: root.createOnlineAccount(model.providerId)
                    }
                }

                // Import from sim card
                ContactListButtonDelegate {
                    id: importFromSimCard
                    objectName: "%1.importFromSimCardButton".arg(root.objectName)

                    expandIcon: true
                    iconSource: "image://theme/import"
                    labelText: i18n.dtr("address-book-app", "Import contacts from SIM card")
                    // Does not show the button if the list is not in a pageStack
                    visible: (typeof(pageStack) !== "undefined") &&
                             ((simList.sims.length > 0) && (simList.present.length > 0))
                    onClicked: {
                        if (pageStack.addPageToNextColumn)
                            pageStack.addPageToNextColumn(pageStack.primaryPage, Qt.resolvedUrl("SIMCardImportPage.qml"),
                                                      {"objectName": "simCardImportPage",
                                                       "targetModel": view.listModel,
                                                       "sims": simList.sims})
                        else
                            pageStack.push(Qt.resolvedUrl("SIMCardImportPage.qml"),
                                           {"objectName": "simCardImportPage",
                                            "targetModel": view.listModel,
                                            "sims": simList.sims})
                    }
                }
            }
        }
        onError: root.error(message)
        onContactClicked: root.contactClicked(contact)
        onSelectionDone: root.selectionDone(items)
        onSelectionCanceled: root.selectionCanceled()
        onContactDisappeared: root.contactDisappeared(contact)
        onCountChanged: {
            if (view.count > 0) {
                view.contactsLoaded = true
            }
        }

        clip: true
        listModel: ContactListModel {
            id: contactsModel

            manager: root.manager
            sortOrders: root.sortOrders
            fetchHint: root.fetchHint
        }
    }

    Column {
        id: indicator

        readonly property bool isBusy: ((view.loading && !view.contactsLoaded) ||
                                        (root.syncing && (view.count === 0)) ||
                                        ((onlineAccountHelper.status == Loader.Ready) &&
                                         (onlineAccountHelper.item.running)))

        anchors.centerIn: view
        spacing: units.gu(2)
        visible: root.showBusyIndicator && isBusy

        ActivityIndicator {
            id: activity

            anchors.horizontalCenter: parent.horizontalCenter
            running: indicator.visible
        }
        Label {
            anchors.horizontalCenter: activity.horizontalCenter
            text: root.syncing ? i18n.dtr("address-book-app", "Syncing...") : i18n.dtr("address-book-app", "Loading...")
        }
    }

    FastScroll {
        id: fastScroll

        listView: view
        // only enable FastScroll if the we have more than 2 pages of content and sections is enabled
        enabled: showSections &&
                 (view.contentHeight > (view.height * 2)) &&
                 (view.height >= minimumHeight) &&
                 (((view.contentY - view.originY) - view.headerItem.height) >= 0)// hearder already invisble

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }

    ButeoSync {
        id: buteoSync
    }

    SIMList {
        id: simList
    }

    Loader {
        id: onlineAccountHelper
        objectName: "onlineAccountHelper"

        property string createAccount: ""
        property bool exitOnFinish: false
        readonly property bool isSearching: (root.filterTerm && root.filterTerm !== "")
        // if running on test mode does not load online account modules
        readonly property string sourceFile: (typeof(runningOnTestMode) !== "undefined") ?
                                      Qt.resolvedUrl("OnlineAccountsDummy.qml") :
                                      Qt.resolvedUrl("OnlineAccountsHelper.qml")

        function start(provider)
        {
            if (root.onlineAccountApplicationId !== "address-book-app") {
                // invoke address book app
                Qt.openUrlExternally("addressbook:///createAccount?providerId=%1&callback=%2.desktop".arg(provider).arg(root.onlineAccountApplicationId))
            } else {
                if (item)
                    item.setupExec(provider)
                else
                    createAccount = provider
            }
        }

        anchors.fill: parent
        asynchronous: true
        source: root.showImportOptions &&
                root.showImportFromAccountOption &&
                (root.count === 0) &&
                !view.favouritesIsSelected &&
                !isSearching ? sourceFile : ""
        onStatusChanged: {
            if (createAccount && (status === Loader.Ready)) {
                item.setupExec(createAccount)
                createAccount = ""
            }
        }

        Connections {
            target: onlineAccountHelper.item ? onlineAccountHelper.item : null
            onFinished: root.onlineAccountFinished()
        }

        Binding {
            target: onlineAccountHelper.item
            property: "applicationId"
            value: root.onlineAccountApplicationId
            when: onlineAccountHelper.status == Loader.Ready
        }
    }

    Keys.onUpPressed: {
        //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
        //because of that we need this
        if (view.currentIndex == 0) {
            pageStack._nextItemInFocusChain(view, false)
        } else {
            view.currentIndex -= 1
        }
    }
    Keys.onDownPressed: {
        //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
        //because of that we need this
        if (view.currentIndex == (view.count - 1)) {
            //DO nothing
        } else {
            view.currentIndex += 1
        }
    }
}
