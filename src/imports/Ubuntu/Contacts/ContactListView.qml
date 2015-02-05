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
Item {
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
      \qmlproperty int detailToPick

      This property holds the detail type to be picked
    */
    property alias detailToPick: view.detailToPick
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
      \qmlproperty bool showAddNewButton

      This property holds if the add new button should be visible or not
    */
    property bool showAddNewButton: false

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
      This handler is called when details button on contact delegate is clicked
    */
    signal infoRequested(QtObject contact)
    /*!
      This handler is called when any contact detail in the list receives a click
    */
    signal detailClicked(QtObject contact, QtObject detail, string action)
    /*!
      This handler is called when add contact detail in the list receives a click
    */
    signal addDetailClicked(QtObject contact, int detailType)
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

    // colapse contacts if the keyboard appears
    Connections {
        target: Qt.inputMethod
        onVisibleChanged: {
            if (Qt.inputMethod.visible) {
                view.currentIndex = -1
            }
        }
    }

    ContactSimpleListView {
        id: view

        property bool showFavourites: true
        property alias favouritesIsSelected: contactsModel.onlyFavorites

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
            height: childrenRect.height

            // AddNewButton
            ContactListButtonDelegate {
                iconSource: "image://theme/add"
                // TRANSLATORS: this refers to a new contact
                labelText: i18n.tr("+ Create New")
                onClicked: root.addNewContactClicked()
                visible: root.showAddNewButton
            }

            // Import from google
            ContactListButtonDelegate {
                expandIcon: true
                iconSource: "image://theme/google"
                // TRANSLATORS: this refers to a new contact
                labelText: i18n.tr("Import contacts from Google")
                visible: (onlineAccountHelper.status === Loader.Ready)
                onClicked: onlineAccountHelper.item.setupExec()
            }
            // TODO: import from simcard

            MostCalledList {
                id: mostCalledView

                anchors {
                    left: parent.left
                    right: parent.right
                }
                parentView: view
                visible: view.favouritesIsSelected
                height: visible && (count > 0) ? childrenRect.height : 0
            }
        }
        onError: root.error(message)
        onInfoRequested: root.infoRequested(contact)
        onDetailClicked: root.detailClicked(contact, detail, action)
        onAddDetailClicked: root.addDetailClicked(contact, detailType)
        onSelectionDone: root.selectionDone(items)
        onSelectionCanceled: root.selectionCanceled()
        onContactDisappeared: root.contactDisappeared(contact)
        clip: true

        listModel: ContactListModel {
            id: contactsModel

            manager: root.manager
            sortOrders: root.sortOrders
            fetchHint: root.fetchHint
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

    Loader {
        id: onlineAccountHelper
        asynchronous: true
        source: (contactList.count === 0) &&
                root.showImportOptions ? Qt.resolvedUrl("OnlineAccountsHelper.qml") : ""
    }
}
