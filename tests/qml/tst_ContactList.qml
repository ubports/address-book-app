/*
 * Copyright (C) 2014 Canonical, Ltd.
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

import QtQuick 2.4
import QtTest 1.0
import Ubuntu.Components 1.3
import Ubuntu.Test 0.1
import Ubuntu.Contacts 0.1

import "ContactUtil.js" as ContactUtilJS
import '../../src/imports/'

Item {
    id: root

    property var application
    property var contactListPageObj

    width: units.gu(40)
    height: units.gu(80)

    application: QtObject {
        id: appMock

        property string callbackApplication: ""
        property bool firstRun: true
        property bool disableOnlineAccounts: true
        property bool isOnline: false

        function elapsed()
        {
        }

        function unsetFirstRun()
        {
        }
    }
    Component {
        id: contactListCmp

        ABContactListPage {
            id: contactListPage
            anchors.fill: parent
            _bottomEdgeEnabled: false
        }

    }

    MainView {
        id: mainView
        pageStack: Item {
            property var contactListPage: null
            property var _bottomEdge: null

            readonly property int columns: 1
            readonly property bool hasKeyboard: false
            property bool bottomEdgeOpened: false
        }

        anchors.fill: parent
    }

    function createContact(firstName, phoneNumber, email) {
        var details = [
           {detail: 'PhoneNumber', field: 'number', value: phoneNumber},
           {detail: 'EmailAddress', field: 'emailAddress', value: email},
           {detail: 'Name', field: 'firstName', value: firstName}
        ];
        return ContactUtilJS.createContact(details, mainView)
    }

    UbuntuTestCase {
        id: contactListTestCase
        name: 'contactListTestCase'

        when: windowShown


        function init()
        {
            root.contactListPageObj = contactListCmp.createObject(mainView, {"contactManager": "memory"})
            waitForRendering(root.contactListPageObj)
        }

        function cleanup()
        {
            root.contactListPageObj.destroy()
        }

        function test_title()
        {
            tryCompare(root.contactListPageObj.header, "title", "Contacts")
        }

        function test_managerProperty()
        {
            tryCompare(root.contactListPageObj, "contactManager", "memory")
        }

        function test_pickMode()
        {
            var listView = findChild(root.contactListPageObj, "contactListView")
            // check initial state
            compare(root.contactListPageObj.pickMode, false)
            compare(root.contactListPageObj.pickMultipleContacts, false)

            // by default the list accepts multi-selection but the selection mode is disabled
            compare(listView.multipleSelection, true)
            compare(listView.isInSelectionMode, false)

            // start multi-selection pick mode
            root.contactListPageObj.startPickMode(false /*isSingle*/, null)

            // check multi-selection mode
            compare(root.contactListPageObj.pickMode, true)
            compare(root.contactListPageObj.pickMultipleContacts, true)
            compare(listView.multipleSelection, true)
            compare(listView.isInSelectionMode, true)

            // start single-selection pick mode
            root.contactListPageObj.startPickMode(true /*isSingle*/, null)

            // check single-selection mode
            compare(root.contactListPageObj.pickMode, true)
            compare(root.contactListPageObj.pickMultipleContacts, false)
            compare(listView.multipleSelection, false)
            compare(listView.isInSelectionMode, true)
        }
    }
}
