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
import '../../src/imports/ContactList'

Item {
    id: root

    property var application
    property var contactListViewObj
    // enable dummy mode for contact list view
    property bool runningOnTestMode: true

    width: units.gu(40)
    height: units.gu(80)


    Component {
        id: contactListCmp

        ContactListView {
            id: contactListPage
            objectName: "contactListViewTest"
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

    function createSignalSpy(target, signalName) {
        var spy = Qt.createQmlObject('import QtTest 1.0;  SignalSpy {}', root, "")
        spy.target = target
        spy.signalName = signalName
        return spy
    }

    UbuntuTestCase {
        id: contactListViewTestCase
        name: 'contactListViewTestCase'

        when: windowShown

        function init()
        {
            root.contactListViewObj = contactListCmp.createObject(mainView, {"manager": "memory"})
            waitForRendering(root.contactListViewObj)
            tryCompare(contactListViewObj, "busy", false)

            var onlineAccountHelper = findChild(root.contactListViewObj, "onlineAccountHelper")
            verify(onlineAccountHelper.sourceFile.indexOf("OnlineAccountsDummy.qml") > 0)
        }

        function cleanup()
        {
            root.contactListViewObj.destroy()
        }

        function test_managerProperty()
        {
            tryCompare(root.contactListViewObj, "manager", "memory")
        }

        function test_addNewButtonVisibility()
        {
            var addNewButton = findChild(root.contactListViewObj, "addNewButton")
            tryCompare(root.contactListViewObj, "showAddNewButton", false)
            tryCompare(addNewButton, "visible", false)
            verify(addNewButton.height === 0)

            root.contactListViewObj.showAddNewButton = true
            tryCompare(root.contactListViewObj, "showAddNewButton", true)
            tryCompare(addNewButton, "visible", true)
            verify(addNewButton.height > 0)
        }

        function test_addNewButtonClick()
        {
            var spy = root.createSignalSpy(root.contactListViewObj, "addNewContactClicked");
            root.contactListViewObj.showAddNewButton = true

            // click
            var addNewButton = findChild(root.contactListViewObj, "addNewButton")
            mouseClick(addNewButton, addNewButton.width / 2, addNewButton.height / 2)

            tryCompare(spy, "count", 1)
        }

        function test_importButtonsVisibility()
        {
            var bottonsHeader = findChild(root.contactListViewObj, "importFromButtons")
            var importButton = findChild(root.contactListViewObj, "contactListViewTest.importFromOnlineAccountButton")
            var onlineAccountHelper = findChild(root.contactListViewObj, "onlineAccountHelper")

            tryCompare(root.contactListViewObj, "showImportOptions", false)
            tryCompare(bottonsHeader, "visible", false)
            tryCompare(importButton, "visible", false)
            tryCompare(onlineAccountHelper, "status", Loader.Null)
            tryCompare(onlineAccountHelper, "isSearching", false)
            verify(importButton.height === 0)

            root.contactListViewObj.showImportOptions = true
            tryCompare(root.contactListViewObj, "showImportOptions", true)
            tryCompare(root.contactListViewObj, "count", 0)
            tryCompare(onlineAccountHelper, "status", Loader.Ready)
            // need to wait a bit more until the list leave the loading state
            tryCompare(bottonsHeader, "visible", true, 10000)
            tryCompare(importButton, "visible", true)
            verify(importButton.height > 0)

            // Button should disapear if the list is not empty
            var newContact = root.createContact("Phablet", "+558187042133", "phablet@ubuntu.com")
            root.contactListViewObj.listModel.saveContact(newContact)
            tryCompare(importButton, "visible", false)

            // Button should not be visible during a search with empty results
            root.contactListViewObj.filterTerm = "xox"
            tryCompare(root.contactListViewObj, "count", 0)
            tryCompare(onlineAccountHelper, "status", Loader.Null)
            tryCompare(importButton, "visible", false)
        }

        function test_importButtonClick()
        {
            // onlineAccountDialog
            var onlineAccountDialog = findChild(root.contactListViewObj, "onlineAccountHelper")
            tryCompare(onlineAccountDialog, "status", Loader.Null)

            root.contactListViewObj.showImportOptions = true
            tryCompare(onlineAccountDialog, "status", Loader.Ready)
            tryCompare(onlineAccountDialog.item, "running", false)

            // click
            var bottonsHeader = findChild(root.contactListViewObj, "importFromButtons")
            var importButton = findChild(root.contactListViewObj, "contactListViewTest.importFromOnlineAccountButton")
            // need to wait a bit more until the list leave the loading state
            tryCompare(bottonsHeader, "visible", true, 10000)
            mouseClick(importButton, importButton.width / 2, importButton.height / 2)
            tryCompare(onlineAccountDialog.item, "running", true)
        }
    }
}
