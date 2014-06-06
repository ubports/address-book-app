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
Item {
    id: root

    property alias view: view
    property alias count: view.count

    property alias showFavourites: view.showFavourites
    property alias showAvatar: view.showAvatar
    property alias titleDetail: view.titleDetail
    property alias titleFields: view.titleFields
    property alias sortOrders: view.sortOrders
    property alias fetchHint: view.fetchHint
    property alias filter: view.filter
    property alias multiSelectionEnabled: view.multiSelectionEnabled
    property alias defaultAvatarImageUrl: view.defaultAvatarImageUrl
    readonly property alias loading: view.loading
    property alias detailToPick: view.detailToPick
    property alias currentIndex: view.currentIndex
    property alias showSections: view.showSections
    property alias manager: view.manager
    property alias fastScrolling: fastScroll.fastScrolling
    property alias leftSideAction: view.leftSideAction
    property alias rightSideActions: view.rightSideActions

    readonly property alias selectedItems: view.selectedItems
    property alias multipleSelection: view.multipleSelection
    property alias listModel: view.listModel
    property alias listDelegate: view.listDelegate
    readonly property alias isInSelectionMode: view.isInSelectionMode

    signal selectionDone(var items)
    signal selectionCanceled()
    signal error(string message)
    signal infoRequested(QtObject contact)
    signal detailClicked(QtObject contact, QtObject detail, string action)
    signal contactDisappeared(QtObject contact)

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

    function changeFilter(newFilter)
    {
        if (root.count > 0) {
            contactsModel._clearModel = true
        }
        root.filter = newFilter
    }

    Rectangle {
        id: itemHeader

        height: units.gu(2)
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        color: Theme.palette.normal.overlay

        Row {
            anchors.fill: parent
            Label {
                id: lblAll

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width / 2
                text: i18n.dtr("address-book-app", "All")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.showFavourites ? UbuntuColors.warmGrey : UbuntuColors.orange
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        //WORKAROUND: clear the model before start populate it with the new contacts
                        //otherwise the model will wait for all contacts before show any new contact
                        root.changeFilter(root.filter)
                        root.showFavourites = false
                    }
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
                text: i18n.dtr("address-book-app", "Favourites")
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

    ContactSimpleListView {
        id: view

        property bool showFavourites: false

        function getSectionText(index) {
            var tag = listModel.contacts[index].tag.tag
            if (tag == "")
                return "#"
            else
                return tag
        }

        anchors {
            top: itemHeader.bottom
            left: parent.left
            right: parent.right
            rightMargin: fastScroll.showing ? fastScroll.width - units.gu(1) : 0
            bottom: parent.bottom

            Behavior on rightMargin {
                UbuntuNumberAnimation {}
            }
        }

        onError: root.error(message)
        onInfoRequested: root.infoRequested(contact)
        onDetailClicked: root.detailClicked(contact, detail, action)
        onSelectionDone: root.selectionDone(items)
        onSelectionCanceled: root.selectionCanceled()
        onContactDisappeared: root.contactDisappeared(contact)
        clip: true

        InvalidFilter {
            id: invalidFilter
        }

        DetailFilter {
            id: favouritesFilter

            detail: ContactDetail.Favorite
            field: Favorite.Favorite
            value: true
            matchFlags: DetailFilter.MatchExactly
        }

        IntersectionFilter {
            id: contactsFilter

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

        listModel: ContactModel {
            id: contactsModel

            property bool _clearModel: false

            manager: root.manager
            sortOrders: root.sortOrders
            fetchHint: root.fetchHint
            filter: {
                if (contactsModel._clearModel) {
                    return invalidFilter
                } else if (view.showFavourites || root.filter) {
                    console.debug("show vaforite")
                    return contactsFilter
                } else {
                    return null
                }
            }

            onErrorChanged: {
                if (error) {
                    console.error("Contact List error:" + error)
                }
            }

            onContactsChanged: {
                //WORKAROUND: clear the model before start populate it with the new contacts
                //otherwise the model will wait for all contacts before show any new contact

                //after all contacts get removed we can populate the model again, this will show
                //new contacts as soon as it arrives in the model
                if (contactsModel._clearModel && contacts.length === 0) {
                    contactsModel._clearModel = false
                }
            }
        }
    }

    FastScroll {
        id: fastScroll

        listView: view
        // only enable FastScroll if the we have more than 2 pages of content
        enabled: view.contentHeight > (view.height * 2)

        anchors {
            top: itemHeader.bottom
            topMargin: units.gu(0.5)
            bottom: parent.bottom
            right: parent.right
        }
    }
}
