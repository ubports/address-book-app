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
      \qmlproperty bool loading

      This property holds when the model still loading new contacts
    */
    readonly property bool loading: busyIndicator.busy
    /*!
      This handler is called when any error occurs in the contact model
    */
    signal error(string message)
    /*!
      This handler is called when any contact int the list receives a click.
    */
    signal contactClicked(string contactId)

    function formatToDisplay(contact, contactDetail, detailFields) {
        if (!contact) {
            return ""
        }

        var detail = contact.detail(contactDetail)
        var values = ""
        for (var i=0; i < detailFields.length; i++) {
            if (i > 0 && detail) {
                values += " "
            }
            if (detail) {
                values +=  detail.value(detailFields[i])
            }
        }

        return values
    }

    clip: true
    snapMode: ListView.NoSnap
    section {
        property: "contact.name.firstName"
        criteria: ViewSection.FirstCharacter
        delegate: ListItem.Header {
            id: listHeader
            text: section
        }
    }

    anchors.fill: parent
    model: contactsModel
    onCountChanged: {
        busyIndicator.ping()
    }

    delegate: ListItem.Subtitled {
        icon: contactListView.showAvatar && contact && contact.avatar && (contact.avatar.imageUrl != "") ?
                  Qt.resolvedUrl(contact.avatar.imageUrl) :
                  "artwork:/avatar-default.png"
        text: contactListView.formatToDisplay(contact, contactListView.titleDetail, contactListView.titleFields)
        subText: contactListView.formatToDisplay(contact, contactListView.subTitleDetail, contactListView.subTitleFields)
        selected: contactListView.multiSelectionEnabled && (contactListView.selectedItems.indexOf(index) != -1)
        onClicked: {
            if (contactListView.isInSelectionModel) {
                contactListView.selectItem(index)
            } else {
                contactListView.currentIndex = index
                contactListView.contactClicked(contact.contactId)
            }
        }

        onPressAndHold: {
            if (contactListView.multiSelectionEnabled) {
                contactListView.startSelection()
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

    // This is a workaround to make sure the spinner will disappear if the model is empty
    // FIXME: implement a model property to say if the model still busy or not
    Item {
        id: busyIndicator

        property bool busy: false

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
            onTriggered: busyIndicator.busy = false
        }
    }
}
