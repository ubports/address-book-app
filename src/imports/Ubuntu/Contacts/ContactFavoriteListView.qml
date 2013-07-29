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

/*!
    \qmltype ContactFavoriteListView
    \inqmlmodule Ubuntu.Contacts 0.1
    \ingroup ubuntu
    \brief The ContactFavoriteListView provides the contact favorite list view

    The ContactFavoriteListView provides a easy way to show the contact favorite
    list view with all default visuals defined by Ubuntu system.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        ContactFavoriteListView {
            anchors.fill: parent
            onContactClicked: console.debug("Contact ID:" + contact.contactId)
        }
    \endqml
*/
OrganicView {
    id: favoriteView

    /*!
      This handler is called when any contact int the list receives a click.
    */
    signal contactClicked(QtObject contact)

    /*!
      \qmlproperty string defaultAvatarImage

      This property holds the default image url to be used when the current contact does
      not contains a photo

      \sa Filter
    */
    property string defaultAvatarImageUrl: "gicon:/avatar-default"
    /*!
      \qmlproperty int currentOperation

      This property holds the current fetch request index
    */
    property int currentOperation: 0

    bigSize: units.gu(17)
    smallSize: units.gu(11)
    margin: units.gu(1)

    model: ContactModel {
        id: favoriteModel

        manager: "galera"

        sortOrders: [
            SortOrder {
                detail: ContactDetail.Name
                field: Name.FirstName
                direction: Qt.AscendingOrder
            }
        ]

        fetchHint: FetchHint {
            detailTypesHint: [ ContactDetail.Avatar,
                               ContactDetail.Name,
                               ContactDetail.PhoneNumber ]
        }

        filter: DetailFilter {
            detail: ContactDetail.Favorite
            field: Favorite.Favorite
            value: true
            matchFlags: DetailFilter.MatchExactly
        }
    }

    delegate: ContactFavoriteDelegate {
        anchors.fill: parent
        onClicked: favoriteView.currentOperation = model.fetchContacts(contactId)
        defaultAvatarImageUrl: root.defaultAvatarImageUrl
    }

    Connections {
        target: model
        onContactsFetched: {
            if (requestId == favoriteView.currentOperation) {
                favoriteView.currentOperation = 0
                // this fetch request can only return one contact
                if(fetchedContacts.length !== 1)
                    return
                favoriteView.contactClicked(fetchedContacts[0])
            }
        }
    }

}
