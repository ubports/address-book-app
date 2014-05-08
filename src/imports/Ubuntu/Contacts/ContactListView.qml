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
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

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
ContactSimpleListView {
    id: root

    property bool showFavourites: false

    header: Rectangle {
        id: itemHeader

        height: units.gu(4)
        anchors {
            left: parent.left
            right: parent.right
        }
        color: UbuntuColors.coolGrey

        Row {
            anchors.fill: parent
            Label {
                id: lblAll

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width / 2
                text: i18n.tr("All")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.showFavourites ? UbuntuColors.warmGrey : UbuntuColors.orange
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.showFavourites = false
                }
            }

            Rectangle {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    margins: units.gu(1)
                }
                width: 1
            }

            Label {
                id: lblFavourites

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width / 2
                text: i18n.tr("Favourites")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.showFavourites ? UbuntuColors.orange : UbuntuColors.warmGrey
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.showFavourites = true
                }
            }
        }
    }

    DetailFilter {
        id: favouritesFilter

        detail: ContactDetail.Favorite
        field: Favorite.Favorite
        value: true
        matchFlags: DetailFilter.MatchExactly
    }

    ContactModel {
        id: contactsModel

        manager: root.manager
        sortOrders: root.sortOrders
        fetchHint: root.fetchHint
        filter: IntersectionFilter {
            filters: {
                var filters = []
                if (root.showFavourites) {
                    filters.push(favouritesFilter)
                }
                if (root.filter) {
                    filters.push(root.filter)
                }
                return filters
            }
        }
        onErrorChanged: {
            if (error) {
                busyIndicator.busy = false
                contactListView.error(error)
            }
        }
    }

    listModel: contactsModel
}
