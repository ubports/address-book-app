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

import "ContactList.js" as Sections

/*!
    \qmltype ContactSimpleListView
    \inqmlmodule Ubuntu.Contacts 0.1
    \ingroup ubuntu
    \brief The ContactSimpleListView provides a simple contact list view

    The ContactSimpleListView provide a easy way to show the contact list view
    with all default visuals defined by Ubuntu system.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        ContactSimpleListView {
            anchors.fill: parent
            onContactClicked: console.debug("Contact ID:" + contactId)
        }
    \endqml
*/

MultipleSelectionListView {
    id: contactListView

    /*!
      \qmlproperty bool showAvatar

      This property holds if the contact avatar will appear on the list or not.
      By default this is set to true.
    */
    property bool showAvatar: true

    /*!
      \qmlproperty list<SortOrder> sortOrders

      This property holds a list of sort orders used by the contacts model.
      \sa SortOrder
    */
    property list<SortOrder> sortOrders : [
        SortOrder {
            detail: ContactDetail.Tag
            field: Tag.Tag
            direction: Qt.AscendingOrder
            blankPolicy: SortOrder.BlanksLast
            caseSensitivity: Qt.CaseInsensitive
        },
        // empty tags will be sorted by display Label
        SortOrder {
            detail: ContactDetail.DisplayLabel
            field: DisplayLabel.Label
            direction: Qt.AscendingOrder
            blankPolicy: SortOrder.BlanksLast
            caseSensitivity: Qt.CaseInsensitive
        }
    ]
    /*!
      \qmlproperty FetchHint fetchHint

      This property holds the fetch hint instance used by the contact model.

      \sa FetchHint
    */
    property var fetchHint : FetchHint {
        detailTypesHint: {
            var hints = [ ContactDetail.Tag,          // sections
                          ContactDetail.DisplayLabel // label
                        ]

            if (contactListView.showAvatar) {
                hints.push(ContactDetail.Avatar)
            }
            return hints
        }
    }
    /*!
      \qmlproperty bool multiSelectionEnabled

      This property holds if the multi selection mode is enabled or not
      By default this is set to false
    */
    property bool multiSelectionEnabled: false
    /*!
      \qmlproperty string defaultAvatarImage

      This property holds the default image url to be used when the current contact does
      not contains a photo
    */
    property string defaultAvatarImageUrl: "image://theme/contact"
    /*!
      \qmlproperty bool loading

      This property holds when the model still loading new contacts
    */
    readonly property bool loading: busyIndicator.busy
    /*!
      \qmlproperty bool showSections

      This property holds if the listview will show or not the section headers
      By default this is set to true
    */
    property bool showSections: true

    /*!
      \qmlproperty string manager

      This property holds the manager uri of the contact backend engine.
      By default this is set to "org.nemomobile.contacts.sqlite"
    */
    property string manager: (typeof(QTCONTACTS_MANAGER_OVERRIDE) !== "undefined") && (QTCONTACTS_MANAGER_OVERRIDE != "") ? QTCONTACTS_MANAGER_OVERRIDE : "org.nemomobile.contacts.sqlite"

    /*!
      \qmlproperty Action leftSideAction

      This property holds the available actions when swipe the contact item from left to right
    */
    property Action leftSideAction

    /*!
      \qmlproperty list<Action> rightSideActions

      This property holds the available actions when swipe the contact item from right to left
    */
    property list<Action> rightSideActions

    /*!
      \qmlproperty highlightSelected

      This property holds if the current contact should be highlighted or not
    */
    property bool highlightSelected: false

    /* internal */
    property var _currentSwipedItem: null

    /*!
      This handler is called when any error occurs in the contact model
    */
    signal error(string message)
    /*!
      This handler is called when any contact in the list receives a click
    */
    signal contactClicked(QtObject contact)
    /*!
      This handler is called when the contact delegate disapear (height === 0) caused by the function call makeDisappear
    */
    signal contactDisappeared(QtObject contact)
    /*!
      Retrieve the contact index inside of the list based on contact id or contact name if the id is empty
    */
    function getIndex(contact)
    {
        var contacts = listModel.contacts
        var contactId = null
        var firstName
        var middleName
        var lastName

        if (contact.contactId !== "qtcontacts:::") {
            contactId = contact.contactId
        } else {
            firstName = contact.name.firstName
            middleName = contact.name.middleName
            lastName = contact.name.lastName
        }

        for (var i = 0, count = contacts.length; i < count; i++) {
            var c = contacts[i]
            if (contactId && (c.contactId === contactId)) {
                return i
            } else if ((c.name.firstName === firstName) &&
                       (c.name.middleName === middleName) &&
                       (c.name.lastName === lastName)) {
                    return i
            }
        }

        return -1
    }

    /*!
      Scroll the list to requested contact if the contact exists in the list
    */
    function positionViewAtContact(contact)
    {
        currentIndex = getIndex(contact)
        positionViewAtIndex(currentIndex, ListView.Center)
    }


    /*!
      Scroll the list to requested contact if the contact exists in the list
    */
    function positionViewAtContactId(contactId)
    {
        var contacts = listModel.contacts

        for (var i = 0, count = contacts.length; i < count; i++) {
            var c = contacts[i]
            if (c.contactId === contactId) {
                currentIndex = i
                positionViewAtIndex(i, ListView.Center)
                return
            }
        }
    }

    /*!
      private
      Fetch contact and emit contact clicked signal
    */
    function _fetchContact(index, contact)
    {
        if (contact) {
            contactFetch.fetchContact(contact.contactId)
        }
    }

    function _updateSwipeState(item)
    {
        if (item.swipping) {
            return
        }

        if (item.swipeState !== "Normal") {
            if (contactListView._currentSwipedItem !== item) {
                if (contactListView._currentSwipedItem) {
                    contactListView._currentSwipedItem.resetSwipe()
                }
                contactListView._currentSwipedItem = item
            }
        } else if (item.swipeState !== "Normal" && contactListView._currentSwipedItem === item) {
            contactListView._currentSwipedItem = null
        }
    }

    highlightFollowsCurrentItem: true
    section {
        property: showSections ? "contact.tag.tag" : ""
        criteria: ViewSection.FirstCharacter
        labelPositioning: ViewSection.InlineLabels
        delegate: SectionDelegate {
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            text: section != "" ? section : "#"
        }
    }

    onCountChanged: {
        busyIndicator.ping()
        dirtyModel.restart()
    }

    listDelegate: ContactDelegate {
        id: contactDelegate

        property var removalAnimation

        function remove()
        {
            removalAnimation.start()
        }

        flicking: contactListView.flicking
        width: parent.width
        selected: (contactListView.multiSelectionEnabled && contactListView.isSelected(contactDelegate))
                  || (!contactListView.isInSelectionMode && contactListView.highlightSelected && (contactListView.currentIndex == index))
        selectionMode: contactListView.isInSelectionMode
        defaultAvatarUrl: contactListView.defaultAvatarImageUrl
        isCurrentItem: ListView.isCurrentItem

        // actions
        leftSideAction: contactListView.leftSideAction
        rightSideActions: contactListView.rightSideActions

        // used by swipe to delete
        removalAnimation: SequentialAnimation {
            alwaysRunToEnd: true

            PropertyAction {
                target: contactDelegate
                property: "ListView.delayRemove"
                value: true
            }
            UbuntuNumberAnimation {
                target: contactDelegate
                property: "height"
                to: 1
            }
            PropertyAction {
                target: contactDelegate
                property: "ListView.delayRemove"
                value: false
            }
            ScriptAction {
                script: contactListView.listModel.removeContact(contact.contactId)
            }
        }

        onClicked: {
            if (contactListView.isInSelectionMode) {
                if (!contactListView.selectItem(contactDelegate)) {
                    contactListView.deselectItem(contactDelegate)
                }
            } else {
                contactListView.currentIndex = index
                contactListView._fetchContact(index, contact)
            }
        }

        onPressAndHold: {
            if (contactListView.multiSelectionEnabled) {
                contactListView.currentIndex = -1
                contactListView.startSelection()
                contactListView.selectItem(contactDelegate)
            }
        }

        onSwippingChanged: contactListView._updateSwipeState(contactDelegate)
        onSwipeStateChanged: contactListView._updateSwipeState(contactDelegate)
    }

    ContactFetch {
        id: contactFetch

        model: root.listModel
        onContactFetched: contactListView.contactClicked(contact)
    }
    // This is a workaround to make sure the spinner will disappear if the model is empty
    // FIXME: implement a model property to say if the model still busy or not
    Item {
        id: busyIndicator

        property bool busy: timer.running || priv.currentOperation !== -1

        function ping()
        {
            timer.restart()
        }

        visible: busy
        anchors.fill: parent

        Timer {
            id: timer

            interval: 3000
            running: true
            repeat: false
        }
    }

    Timer {
        id: dirtyModel

        interval: 1000
        running: false
        repeat: false
        onTriggered: Sections.initSectionData(contactListView)
    }

    QtObject {
        id: priv

        property int currentOperation: -1
        property int pendingTargetIndex: 0
        property variant pendingTargetMode: null
    }
}
