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
            onContactClicked: console.debug("Contact ID:" + contactId)
        }
    \endqml
*/
ContactSimpleListView {
    id: root

    header: ContactFavoriteListView {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        height: count > 0 ? implicitHeight : 0
        onContactClicked: root.contactClicked(contactId)
        defaultAvatarImageUrl: root.defaultAvatarImageUrl
    }
}
