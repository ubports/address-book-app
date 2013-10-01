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

    header: Column {
        width: parent.width
        height: favouritesList.count > 0 ? childrenRect.height : 0

        ContactSimpleListView {
            id: favouritesList

            header: ListItem.Header {
                height: units.gu(5)
                text: i18n.tr("Favourites")
            }

            anchors {
                left: parent.left
                right: parent.right
            }
            height: (count > 0 && !root.isInSelectionMode) ? contentHeight : 0
            onContactClicked: root.contactClicked(contact)
            defaultAvatarImageUrl: root.defaultAvatarImageUrl
            multiSelectionEnabled: false
            interactive: false
            showSections: false
            filter: DetailFilter {
                detail: ContactDetail.Favorite
                field: Favorite.Favorite
                value: true
                matchFlags: DetailFilter.MatchExactly
            }

            Behavior on height {
                UbuntuNumberAnimation {}
            }

            // WORKAROUND: Due a bug on the SDK Page component the page is nto correct positioned if it changes
            // the size dynamically
            onHeightChanged: {
                root.contentY = -contentHeight * 2
                root.returnToBounds()
            }
        }
        ListItem.Header {
            height: favouritesList.count > 0 ? units.gu(5) : 0
            visible: height > 0
            text: i18n.tr("All contacts")
        }
    }
}
