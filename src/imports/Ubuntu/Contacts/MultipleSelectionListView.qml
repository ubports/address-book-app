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
import Ubuntu.Components.Popups 0.1 as Popups

/*!
    \qmltype ContactSimpleListView
    \inqmlmodule Ubuntu.Contacts 0.1
    \ingroup ubuntu
    \brief The MiltipleSelectionListView provides a ListView with support to multiple selection

    The MiltipleSelectionListViewprovides a ListView with support to multiple selection which can be used by any
    application.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        MiltipleSelectionListView {
            id: view
            anchors.fill: paret
            model: 100
            delegate: Rectangle {
                width: parent.width
                height: 100
                color: view.selectedItems.indexOf(index) == -1 ? "white" : "blue"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (view.isInSelectionModel) {
                            view.selectItem(index)
                        }
                    }
                    onPressAndHold: view.startSelection()
                }
            }
            onSelectionDone: console.debug("Selected items:" + view.selectedItems)
        }
    \endqml
*/

ListView {
    id: listView

    /*!
      \qmlproperty list<int> selectedItems

      This property holds the index of selected items
    */
    property variant selectedItems: []
    /*!
      \qmlproperty Action acceptAction

      This property holds the action used into the accept button
    */
    property alias acceptAction: sheet.acceptAction
    /*!
      \qmlproperty Action acceptAction

      This property holds the action used into the reject button
    */
    property alias rejectAction: sheet.rejectAction
    /*!
      \qmlproperty bool showActionButtons

      This property holds if the default sheet element must be visible during the selection
      By default this is set to true
    */
    property alias showActionButtons: sheet.enabled
    /*!
      \qmlproperty bool isInSelectionMode

      This property holds a list with the index of selected items
    */
    readonly property bool isInSelectionMode: state === "selection"
    /*!
      This handler is called when the selection mode is finished without be canceled
    */
    signal selectionDone(var items)

    /*!
      Start the selection mode on the list view.
    */
    function startSelection()
    {
        state = "selection"
    }
    /*!
      Add a index into the list of selected items
      Returns true if the item was marked as selected or false if the item is already selected
    */
    function selectItem(index)
    {
        if (listView.selectedItems.indexOf(index) == -1) {
            var newItems = listView.selectedItems
            newItems.push(index)
            listView.selectedItems = newItems
            return true
        } else {
            return false
        }
    }
    /*!
      Remove the index from the selected list
    */
    function deselectItem(index)
    {
        if (listView.selectedItems.indexOf(index) != -1) {
            var newItems = []
            var oldItems = listView.selectedItems
            for (var i=0; i < oldItems.length; i++) {
                if (oldItems[i] != index) {
                    newItems.push(oldItems[i])
                }
            }
            listView.selectedItems = newItems
            return true
        } else {
            return false
        }
    }
    /*!
      Finish the selection mode with sucess
    */
    function endSelection()
    {
        selectionDone(listView.selectedItems)
        cancelSelection()
    }
    /*!
      Cancel the selection
    */
    function cancelSelection()
    {
        selectedItems = []
        state = ""
    }

    states: [
        State {
            name: "selection"
            PropertyChanges {
                target: sheet
                active: true
            }
            PropertyChanges {
                target: listView
                bottomMargin: sheet.height
            }
        }
    ]

    DialogButtons {
        id: sheet

        property bool active: false
        property bool enabled: true

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: visible ? units.gu(6) : 0
        visible: active && enabled

        onReject: listView.cancelSelection()
        onAccept: listView.endSelection()
    }
}
