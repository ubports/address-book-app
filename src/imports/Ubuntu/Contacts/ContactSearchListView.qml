/*
 * Copyright (C) 2013 Canonical, Ltd.
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

/*!
    \qmltype ContactSearchListView
    \inqmlmodule Ubuntu.Contacts 0.1
    \ingroup ubuntu
    \brief The ContactSearchListView provides a simple contact list view

    The ContactSearchListView provide a easy way to show the contact list view
    with all default visuals defined by Ubuntu system.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        ContactSearchListView {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            onContactClicked: console.debug("Contact ID:" + contactId)
        }
    \endqml
*/

ListView {
    id: contactListView

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
      \qmlproperty string defaultAvatarImage

      This property holds the default image url to be used when the current contact does
      not contains a photo
    */
    property string defaultAvatarImageUrl: "image://gicon/avatar-default"
    /*!
      \qmlproperty int currentOperation

      This property holds the current fetch request index
    */
    property int currentOperation: -1
    /*!
      \qmlproperty int detailToPick

      This property holds the detail type to be picked
    */
    property int detailToPick: Contact.PhoneNumber
    /*!
      \qmlproperty list<int> detailFieldsToDisplay

      This property holds the list of all fields which will be used to display the contact subtitle in the delegate
      By default this is set to [ PhoneNumber.Number ]
    */
    property variant detailFieldsToDisplay: [ PhoneNumber.Number ]
    /*!
      \internal \qmlproperty variant ___selectedDetail
    */
    property variant ___selectedDetail: null
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

    function formatToDisplay(contact, contactDetail, detailFields, detail) {
        if (!contact) {
            return ""
        }

        if (!detail) {
            detail = contact.detail(contactDetail)
        }

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
    orientation: ListView.Horizontal
    height: units.gu(12)
    spacing: units.gu(1)

    model: contactsModel
    delegate: contactSearchDelegate

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
            detailTypesHint: contactListView.detailToPick != 0 ?
                                 [contactListView.titleDetail, ContactDetail.Avatar, contactListView.detailToPick] :
                                 [contactListView.titleDetail, ContactDetail.Avatar]
        }

        onErrorChanged: {
            if (error) {
                contactListView.error(error)
            }
        }

    }

    Connections {
        target: model
        onContactsFetched: {
            if (requestId == contactListView.currentOperation) {
                contactListView.currentOperation = -1
                // this fetch request can only return one contact
                if(fetchedContacts.length !== 1)
                    return

                if (contactListView.detailToPick == 0)
                    contactListView.contactClicked(fetchedContacts[0])
                else if (___selectedDetail != "")
                    contactListView.detailClicked(fetchedContacts[0], ___selectedDetail)
            }
        }
    }

    Component {
        id: contactSearchDelegate
        Row {
            anchors {
                top: parent.top
                topMargin: units.gu(1)
            }
            height: childrenRect.height
            width: childrenRect.width
            spacing: units.gu(1)

            // if we are picking the details, repeat one entry per detail
            // but if we are only picking the contact itself,
            Repeater {
                id: numberRepeater
                model: (contactListView.detailToPick != 0  && contact.details(contactListView.detailToPick).length > 0) ?
                           contact.details(contactListView.detailToPick) : [""]
                UbuntuShape {
                    id: img

                    anchors.top: parent.top
                    width: units.gu(11)
                    height: units.gu(11)

                    image: Image {
                        fillMode: Image.PreserveAspectCrop
                        source: (contact.avatar && contact.avatar.imageUrl != "") ?
                                    Qt.resolvedUrl(contact.avatar.imageUrl) :
                                    defaultAvatarImageUrl
                        asynchronous: true
                    }

                    Rectangle {
                        id: bgLabel

                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        height: units.gu(5.5)
                        color: "black"
                        opacity: 0.7
                    }

                    Label {
                        id: titleLabel

                        anchors {
                            left: bgLabel.left
                            leftMargin: units.gu(1.0)
                            top: bgLabel.top
                            topMargin: units.gu(0.5)
                            right: bgLabel.right
                        }
                        height: units.gu(2.5)
                        verticalAlignment: Text.AlignVCenter
                        text: formatToDisplay(contact, titleDetail, titleFields)
                        elide: Text.ElideRight
                        color: "white"
                        fontSize: "medium"
                    }

                    Label {
                        id: subTitleLabel

                        anchors {
                            left: titleLabel.left
                            top: titleLabel.bottom
                            right: titleLabel.right
                        }
                        height: units.gu(1)
                        verticalAlignment:  Text.AlignVCenter
                        text: modelData === "" ? modelData : formatToDisplay(contact, detailToPick, detailFieldsToDisplay, modelData)
                        elide: Text.ElideRight
                        fontSize: "x-small"
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (contactListView.currentOperation !== -1) {
                                return;
                            }

                            if (detailToPick !== 0) {
                                ___selectedDetail = modelData;
                            }

                            contactListView.currentIndex = index
                            contactListView.currentOperation = contactsModel.fetchContacts(contact.contactId)
                        }
                    }
                }
            }
        }

    }
}
