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
import Ubuntu.Telephony 0.1

import "ContactList.js" as Sections
import "Contacts.js" as ContactsJS


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
      \qmlproperty int subTitleDetail

      This property holds the contact detail which will be used to display the contact subtitle in the delegate
      By default this is set to ContactDetail.Organization
    */
    property int subTitleDetail: ContactDetail.Organization
    /*!
      \qmlproperty list<int> subTitleFields

      This property holds the list of all fields which will be used to display the contact subtitle in the delegate
      By default this is set to [ Organization.Name ]
    */
    property variant subTitleFields: [ Organization.Name ]
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
    property string defaultAvatarImageUrl: "image://gicon/avatar-default"
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
        }
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

            Rectangle {
                z: -1
                anchors.fill: parent
                color: Theme.palette.normal.background
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    priv.activeSection = listHeader.text
                    contactListView.expanded = !contactListView.expanded
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

        property var contact: model.contact
        property int _index: index
        property variant loaderDelegate: loaderDelegate
        property int delegateHeight: item.childrenRect.height

        sourceComponent: height > units.gu(5) ? delegateItem : null
        asynchronous: false
        height: contactListView.expanded ? (((currentContactExpanded == index) && detailToPick != 0) ? delegateHeight : units.gu(10) ) : 0
        onHeightChanged: {
            priv.animating = (height != 0) && (height != units.gu(10))
        }
        width: parent.width
        visible: loaderDelegate.status == Loader.Ready

        Behavior on height {
            UbuntuNumberAnimation { }
        }

        Binding {
            target: loaderDelegate.item
            property: "index"
            value: loaderDelegate._index
            when: loaderDelegate.status == Loader.Ready
        }
        Binding {
            target: loaderDelegate.item
            property: "itemDelegate"
            value: loaderDelegate.loaderDelegate
            when: loaderDelegate.status == Loader.Ready
        }
    }

    onAnimatingChanged: {
        if (!animating && priv.pendingTargetIndex >= 0) {
            contactListView.positionViewAtIndex(priv.pendingTargetIndex, priv.pendingTargetMode)
            priv.pendingTargetIndex = -1
            priv.pendingTargetMode = null
        }
    }

    Component {
       id: delegateItem
       Item {
           id: item

           property int index: -1
           property variant itemDelegate: null

           height: delegate.detailsShown ? (delegate.height + pickerLoader.height) : delegate.height
           width: parent ? parent.width : 0
           clip: true

            Behavior on height {
                UbuntuNumberAnimation { }
            }

            Connections {
                target: contactListView
                onCurrentContactExpandedChanged: {
                    if (index != currentContactExpanded) {
                        delegate.detailsShown = false
                    }
                }
            }

            ListItem.Empty {
                id: delegate
                property bool detailsShown: false
                height: units.gu(10)
                showDivider : false

                selected: contactListView.multiSelectionEnabled && item.itemDelegate && contactListView.isSelected(item.itemDelegate)
                removable: contactListView.swipeToDelete && !detailsShown && !contactListView.isInSelectionMode
                UbuntuShape {
                    id: avatar

                    height: units.gu(7)
                    width: units.gu(7)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    image: Image {
                        fillMode: Image.PreserveAspectCrop
                        source: contactListView.showAvatar && contact && contact.avatar && (contact.avatar.imageUrl != "") ?
                                        Qt.resolvedUrl(contact.avatar.imageUrl) :
                                        contactListView.defaultAvatarImageUrl
                    }
                }

                Row {
                    spacing: units.gu(1)
                    anchors {
                        left: avatar.right
                        leftMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                        right: selectionMark.left
                    }
                    Label {
                        id: name
                        height: paintedHeight
                        text: ContactsJS.formatToDisplay(contact, contactListView.titleDetail, contactListView.titleFields)
                        fontSize: "large"
                    }
                    Label {
                        id: company
                        height: paintedHeight
                        text: ContactsJS.formatToDisplay(contact, contactListView.subTitleDetail, contactListView.subTitleFields)
                        fontSize: "medium"
                        opacity: 0.2
                    }
                }

                Rectangle {
                    id: selectionMark

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }

                    color: "black"
                    width: delegate.selected ? units.gu(5) : 0
                    visible: width > 0
                    Icon {
                        name: "select"
                        height: units.gu(3)
                        width: height
                        anchors.centerIn: parent
                    }
                }

                onClicked: {
                    if (contactListView.isInSelectionMode) {
                        if (!contactListView.selectItem(item.itemDelegate)) {
                            contactListView.deselectItem(item.itemDelegate)
                        }
                        return
                    }
                    if (currentContactExpanded == index) {
                        currentContactExpanded = -1
                        detailsShown = false
                        return
                    // check if we should expand and display the details picker
                    } else if (detailToPick !== 0){
                        currentContactExpanded = index
                        detailsShown = !detailsShown
                        return
                    }
                    if (priv.currentOperation !== -1) {
                        return
                    }
                    contactListView.currentIndex = index
                    priv.currentOperation = contactsModel.fetchContacts(contact.contactId)
                }

                onPressAndHold: {
                    if (contactListView.multiSelectionEnabled) {
                        contactListView.startSelection()
                        contactListView.selectItem(itemDelegate)
                    }
                }

                onItemRemoved: {
                    contactsModel.removeContact(contact.contactId)
                }

                backgroundIndicator: Rectangle {
                    anchors.fill: parent
                    color: Theme.palette.selected.base
                    Label {
                        text: "Delete"
                        anchors {
                            fill: parent
                            margins: units.gu(2)
                        }
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment:  delegate.swipingState === "SwipingLeft" ? Text.AlignLeft : Text.AlignRight
                    }
                }
            }
            Image {
                width: units.gu(2)
                height: units.gu(2)
                anchors.right: parent.right
                anchors.rightMargin: units.gu(3)
                anchors.top: parent.top
                anchors.topMargin: units.gu(2)
                visible: delegate.detailsShown
                source: contactListView.defaultAvatarImageUrl
                MouseArea {
                   anchors.fill: parent
                   onClicked: applicationUtils.switchToAddressbookApp("contact://" + contact.contactId)
                }
            }
            Loader {
                id: pickerLoader

                source: delegate.detailsShown ? Qt.resolvedUrl("ContactDetailPickerDelegate.qml") : ""
                anchors {
                    top: delegate.bottom
                    left: parent.left
                    right: parent.right
                }
                onStatusChanged: {
                    if (status == Loader.Ready) {
                        pickerLoader.item.contactsModel = contactsModel
                        pickerLoader.item.detailType = detailToPick
                        pickerLoader.item.contactId = contact.contactId
                    }
                }
            }
            ListItem.ThinDivider {
                anchors {
                    bottom: pickerLoader.bottom
                    right: parent.right
                    left: parent.left
                }
            }

            Connections {
                target: pickerLoader.item
                onDetailClicked: detailClicked(contact, detail)
            }
        }
    }

    ContactModel {
        id: contactsModel

        manager: "galera"
        sortOrders: [
            SortOrder {
                id: sortOrder

                detail: ContactDetail.Name
                field: Name.FirstName
                direction: Qt.AscendingOrder
            }
        ]

        fetchHint: FetchHint {
            detailTypesHint: root.showAvatar ? [contactListView.titleDetail, contactListView.subTitleDetail, ContactDetail.Avatar] :
                                               [contactListView.titleDetail, contactListView.subTitleDetail]
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
        onTriggered: priv.scrollToSection()
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

        function scrollToSection() {
            var index = Sections.getIndexFor(activeSection)
            contactListView.positionViewAtIndex(index, ListView.Beginning)
            activeSection = ""
        }
    }
}
