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
    \brief The MultipleSelectionListView provides a ListView with support to multiple selection

    The MultipleSelectionListViewprovides a ListView with support to multiple selection which can be used by any
    application.

    Example:
    \qml
        import Ubuntu.Contacts 0.1

        MultipleSelectionListView {
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
      \qmlproperty model selectedItems

      This property holds the list of selected items
    */
    readonly property variant selectedItems: visualModel.selectedItems
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
      \qmlproperty model listModel

      This property holds the model providing data for the list.
    */
    property alias listModel: visualModel.model
    /*!
      \qmlproperty Component listDelegate

      The delegate provides a template defining each item instantiated by the view.
    */
    property alias listDelegate: visualModel.delegate

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
      Check if the item is selected
      Returns true if the item was marked as selected or false if the item is unselected
    */
    function isSelected(item)
    {
        return (item.VisualDataModel.inSelected == true)
    }
    /*!
      Mark the item as selected
      Returns true if the item was marked as selected or false if the item is already selected
    */
    function selectItem(item)
    {
        if (item.VisualDataModel.inSelected) {
            return false
        } else {
            item.VisualDataModel.inSelected = true
            return true
        }
    }
    /*!
      Remove the index from the selected list
    */
    function deselectItem(item)
    {
        var result = false
        if (item.VisualDataModel.inSelected) {
            item.VisualDataModel.inSelected = false
            result = true
        }
        if (selectedItems.count == 0) {
            cancelSelection()
        }
        return result
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
        if (selectedItems.count > 0) {
            selectedItems.remove(0, selectedItems.count)
        }
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

    model: visualModel

    MultipleSelectionVisualModel {
        id: visualModel
    }

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
