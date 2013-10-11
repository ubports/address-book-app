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

import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

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
      \qmlproperty bool swipeToDelete

      This property holds if the swipe to delete contact gesture is enabled or not
      By default this is set to false.
    */
    property bool swipeToDelete: false
    /*!
      \qmlproperty bool expanded

      This property holds if the list is expaned or not
      By default this is set to true.
    */
    property bool expanded: true
    /*!
      \qmlproperty int titleDetail

      This property holds the contact detail which will be used to display the contact title in the delegate
      By default this is set to ContactDetail.Name.
    */
    property int titleDetail: ContactDetail.Name
    /*!
      \qmlproperty list<int> titleFields

      This property holds the list of all fields which will be used to display the contact title in the delegate
      By default this is set to [ Name.FirstName, Name.LastName ]
    */
    property variant titleFields: [ Name.FirstName, Name.LastName ]
    /*!
      \qmlproperty list<SortOrder> sortOrders

      This property holds a list of sort orders used by the contacts model.
      \sa SortOrder
    */
    property alias sortOrders: contactsModel.sortOrders
    /*!
      \qmlproperty FetchHint fetchHint

      This property holds the fetch hint instance used by the contact model.

      \sa FetchHint
    */
    property alias fetchHint: contactsModel.fetchHint
    /*!
      \qmlproperty Filter filter

      This property holds the filter instance used by the contact model.

      \sa Filter
    */
    property alias filter: contactsModel.filter
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
    property string defaultAvatarImageUrl: Qt.resolvedUrl("./artwork/contact-default.png")
    /*!
      \qmlproperty bool loading

      This property holds when the model still loading new contacts
    */
    readonly property bool loading: busyIndicator.busy
    /*!
      \qmlproperty int detailToPick

      This property holds the detail type to be picked
    */
    property int detailToPick: 0
    /*!
      \qmlproperty int currentContactExpanded

      This property holds the current contact expanded
    */
    property int currentContactExpanded: -1

    /*!
      \qmlproperty bool animating

      This property holds if the list is on animating state (expanding/collapsing)
    */
    readonly property alias animating: priv.animating

    /*!
      \qmlproperty bool showSections

      This property holds if the listview will show or not the section headers
      By default this is set to true
    */
    property bool showSections: true
    /*!
      This handler is called when any error occurs in the contact model
    */
    signal error(string message)
    /*!
      This handler is called when any contact int the list receives a click.
    */
    signal contactClicked(QtObject contact)
    /*!
      This handler is called when any contact detail in the list receives a click
    */
    signal detailClicked(QtObject contact, QtObject detail)

    /*!
      Retrieve the contact index inside of the list
    */
    function getIndex(contact)
    {
        var contacts = listModel.contacts;

        for (var i = 0, count = contacts.length; i < count; i++) {
            var itemId = contacts[i].contactId
            if (itemId === contact.contactId) {
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
        if (expanded) {
            positionViewAtIndex(getIndex(contact), ListView.Center)
        } else {
            priv.pendingTargetIndex = getIndex(contact)
            priv.pendingTargetMode = ListView.Center
            expanded = true
            dirtyHeightTimer.restart()
        }
    }

    /*!
      private
      Fetch contact and emit contact clicked signal
    */
    function _fetchContact(index, contact)
    {
        if (priv.currentOperation !== -1) {
            return
        }
        contactListView.currentIndex = index
        priv.currentOperation = contactsModel.fetchContacts(contact.contactId)
    }

    clip: true
    snapMode: ListView.SnapToItem
    section {
        property: showSections ? "contact.tag.tag" : ""
        criteria: ViewSection.FirstCharacter
        labelPositioning: ViewSection.InlineLabels | ViewSection.CurrentLabelAtStart
        delegate: ListItem.Header {
            id: listHeader
            text: section
            height: units.gu(4)

            Rectangle {
                z: -1
                anchors.fill: parent
                color: Theme.palette.normal.background
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!priv.animating) {
                        priv.activeSection = listHeader.text
                        contactListView.expanded = !contactListView.expanded
                    }
                }
            }
        }
    }

    acceptAction.text: i18n.tr("Delete")

    listModel: contactsModel
    onCountChanged: {
        busyIndicator.ping()
        dirtyModel.restart()
    }

    listDelegate: Loader {
        id: loaderDelegate

        property bool loaded: false
        property var contact: model.contact
        property int _index: index
        property int delegateHeight: item ? item.implicitHeight : 0
        property int targetHeight: ((currentContactExpanded == index) && detailToPick != 0) ?  delegateHeight : units.gu(6)
        property bool detailsShown: false

        source: Qt.resolvedUrl("ContactDelegate.qml")
        active: true
        height: targetHeight
        width: parent.width
        visible: loaderDelegate.status == Loader.Ready
        state: contactListView.expanded ? "" : "collapsed"
        // WORKAROUND: for some unknown reason, after collapsing the contact list
        // the delegate height auto update will not work anymore.
        onTargetHeightChanged: height = targetHeight

        Connections {
            target: contactListView
            onCurrentContactExpandedChanged: {
                if (index != currentContactExpanded) {
                    loaderDelegate.detailsShown = false
                }
            }
        }

        Binding {
            target: loaderDelegate.item
            property: "index"
            value: loaderDelegate._index
            when: (loaderDelegate.status == Loader.Ready)
        }

        Binding {
            target: loaderDelegate.item
            property: "selected"
            value: contactListView.multiSelectionEnabled &&
                   contactListView.isSelected &&
                   contactListView.isSelected(loaderDelegate)
            when: (loaderDelegate.status == Loader.Ready)
        }

        Binding {
            target: loaderDelegate.item
            property: "removable"
            value: contactListView &&
                   contactListView.swipeToDelete &&
                   !detailsShown &&
                   !contactListView.isInSelectionMode
            when: (loaderDelegate.status == Loader.Ready)
        }

        Binding {
            target: loaderDelegate.item
            property: "defaultAvatarUrl"
            value: contactListView.defaultAvatarImageUrl
            when: (loaderDelegate.status == Loader.Ready)
        }

        Binding {
            target: loaderDelegate.item
            property: "detailsShown"
            value: loaderDelegate.detailsShown
            when: (loaderDelegate.status == Loader.Ready)
        }

        Binding {
            target: loaderDelegate.item
            property: "selectMode"
            value: contactListView.isInSelectionMode
            when: (loaderDelegate.status == Loader.Ready)
        }

        Connections {
            target: loaderDelegate.item
            onContactClicked: {
                if (contactListView.isInSelectionMode) {
                    if (!contactListView.selectItem(loaderDelegate)) {
                        contactListView.deselectItem(loaderDelegate)
                    }
                    return
                }
                if (contactListView.currentContactExpanded == index) {
                    contactListView.currentContactExpanded = -1
                    loaderDelegate.detailsShown = false
                    return
                // check if we should expand and display the details picker
                } else if (detailToPick !== 0) {
                    contactListView.currentContactExpanded = index
                    loaderDelegate.detailsShown = !detailsShown
                    return
                }

                contactListView._fetchContact(index, contact)
            }
            onPressAndHold: {
                if (contactListView.multiSelectionEnabled) {
                    contactListView.startSelection()
                    contactListView.selectItem(loaderDelegate)
                }
            }
        }

        Timer {
            id: dirtyItem

            interval: 100
            running: false
            repeat: false
            onTriggered: loaderDelegate.active = (state == "")
        }

        states: [
            State {
                name: "collapsed"
                PropertyChanges {
                    target: loaderDelegate
                    height: 0
                    restoreEntryValues: false
                }
                PropertyChanges {
                    target: loaderDelegate
                    active: false
                    restoreEntryValues: false
                }
            }
        ]

        transitions: [
            Transition {
                to: "collapsed"
                onRunningChanged: priv.animating = running
            },
            Transition {
                to: ""
                onRunningChanged: priv.animating = running
                SequentialAnimation {
                    PropertyAction {
                        target: loaderDelegate
                        property: "height"
                        value: targetHeight
                    }
                    ScriptAction {
                        // wait for list get fully expanded and cached delegates updated
                        script: dirtyItem.restart()
                    }
                }

            }
        ]
    }

    ContactModel {
        id: contactsModel

        manager: "galera"
        sortOrders: [
            SortOrder {
                id: sortOrder

                detail: ContactDetail.DisplayLabel
                field: DisplayLabel.Label
                direction: Qt.AscendingOrder
                blankPolicy: SortOrder.BlanksLast
                caseSensitivity: Qt.CaseInsensitive
            }
        ]

        fetchHint: FetchHint {
            detailTypesHint: {
                var hints = [ contactListView.titleDetail, ContactDetail.Tag, ContactDetail.DisplayLabel ]

                if (contactListView.showAvatar) {
                    hints.push(ContactDetail.Avatar)
                }
                return hints
            }
        }

        onErrorChanged: {
            if (error) {
                busyIndicator.busy = false
                contactListView.error(error)
            }
        }

    }

    onContentHeightChanged: {
        if (priv.activeSection !== "") {
            dirtyHeightTimer.restart()
        }
    }

    Timer {
        id: dirtyHeightTimer

        interval: 1
        running: false
        repeat: false
        onTriggered: priv.scrollList()
    }

    Connections {
        target: listModel
        onContactsFetched: {
            if (requestId == priv.currentOperation) {
                priv.currentOperation = -1
                // this fetch request can only return one contact
                if(fetchedContacts.length !== 1)
                    return
                contactListView.contactClicked(fetchedContacts[0])
            }
        }
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

            interval: 6000
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
        property string activeSection: ""
        property bool animating: false

        property int pendingTargetIndex: 0
        property variant pendingTargetMode: null

        function scrollList() {
            if (activeSection) {
                var targetSection = activeSection
                activeSection = ""
                var index = Sections.getIndexFor(targetSection)
                contactListView.positionViewAtIndex(index, ListView.Beginning)
            } else if (priv.pendingTargetIndex != -1) {
                contactListView.positionViewAtIndex(priv.pendingTargetIndex, priv.pendingTargetMode)
                priv.pendingTargetIndex = -1
                priv.pendingTargetMode = null
            }
        }
    }
}
