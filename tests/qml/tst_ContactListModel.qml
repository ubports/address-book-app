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

Item {
    id: root

    property var application
    property var contactListModelObj

    width: units.gu(40)
    height: units.gu(80)

    Component {
        id: contactListModelCmp

        ContactListModel {
            id: contactListModel

            property int contactCount: contacts ? contacts.length : 0

            manager: "memory"
            Component.onCompleted: importContacts(Qt.resolvedUrl("../data/tst_ContactListModel_data.vcf"))
        }
    }

    UbuntuTestCase {
        id: contactListModelTestCase
        name: 'contactListModelTestCase'

        when: windowShown

        function init()
        {
            root.contactListModelObj = contactListModelCmp.createObject(root)
            //waitForRendering(root.contactListModelObj)
        }

        function cleanup()
        {
            root.contactListModelObj.destroy()
        }

        function test_contactImport()
        {
            tryCompare(root.contactListModelObj, "contactCount", 3)
        }

        function test_searchByPhoneNumber()
        {
            root.contactListModelObj.filterTerm = "555"
            tryCompare(root.contactListModelObj, "contactCount", 1)

            root.contactListModelObj.filterTerm = "5"
            tryCompare(root.contactListModelObj, "contactCount", 2)

            root.contactListModelObj.filterTerm = "6"
            tryCompare(root.contactListModelObj, "contactCount", 3)
        }

        function test_searchByContactName()
        {
            root.contactListModelObj.filterTerm = "First"
            tryCompare(root.contactListModelObj, "contactCount", 1)

            root.contactListModelObj.filterTerm = "Fulano"
            tryCompare(root.contactListModelObj, "contactCount", 2)

            root.contactListModelObj.filterTerm = "F"
            tryCompare(root.contactListModelObj, "contactCount", 3)

            root.contactListModelObj.filterTerm = "tal6"
            tryCompare(root.contactListModelObj, "contactCount", 1)
        }

        function test_searchByNameAndNumber()
        {
            root.contactListModelObj.filterTerm = "First"
            tryCompare(root.contactListModelObj, "contactCount", 1)

            root.contactListModelObj.filterTerm = "555"
            tryCompare(root.contactListModelObj, "contactCount", 1)

            root.contactListModelObj.filterTerm = "1"
            tryCompare(root.contactListModelObj, "contactCount", 3)
        }
    }
}
