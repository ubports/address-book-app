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

import QtQuick 2.2
import QtTest 1.0
import Ubuntu.Components 1.1
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
        }

    }

    MainView {
        id: mainView
        anchors.fill: parent
        useDeprecatedToolbar: false
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
            tryCompare(root.contactListPageObj, "title", "Contacts")
        }

        function test_managerProperty()
        {
            tryCompare(root.contactListPageObj, "contactManager", "memory")
        }
    }
}
