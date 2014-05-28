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
import Ubuntu.Components 0.1
import Ubuntu.Test 0.1

import '../../src/imports/ContactEdit'
import '../../src/imports/Ubuntu/Contacts'

Item {

    id: root

    width: units.gu(40)
    height: units.gu(80)

    MainView {
        id: mainView
        anchors.fill: parent

        ListModel {
            // dummy data model.
            id: dummyDataModel

            signal contactsFetched
        }

        ContactEditor {
            id: contactEditor
            anchors.fill: parent
            model: dummyDataModel
            contact: createEmptyContact('')
        }
    }

    function createEmptyContact(phoneNumber) {
        var details = [
           {detail: 'PhoneNumber', field: 'number', value: phoneNumber},
           {detail: 'EmailAddress', field: 'emailAddress', value: ''},
           {detail: 'OnlineAccount', field: 'accountUri', value: ''},
           {detail: 'Address', field: 'street', value: ''},
           {detail: 'Name', field: 'firstName', value: ''},
           {detail: 'Organization', field: 'name', value: ''}
       ]

        var newContact = Qt.createQmlObject('import QtContacts 5.0; Contact{ }', mainView)
        var detailSourceTemplate = 'import QtContacts 5.0; %1{ %2: "%3" }'
        for (var i=0; i < details.length; i++) {
            var detailMetaData = details[i]
            var newDetail = Qt.createQmlObject(detailSourceTemplate.arg(detailMetaData.detail).arg(detailMetaData.field).arg(detailMetaData.value), mainView)
            newContact.addDetail(newDetail)
        }
        return newContact
    }

    UbuntuTestCase {
        id: contactEditorTestCase
        name: 'contactEditorTestCase'

        when: windowShown

        function init() {
            waitForRendering(contactEditor)
        }

        function test_fillRequiredFieldsMustEnableSaveButton_data() {
            return [
                {objectName: 'firstName'},
                {objectName: 'lastName'},
                {objectName: 'phoneNumber_0'}
            ]
        }

        function test_fillRequiredFieldsMustEnableSaveButton(data) {
            var saveButton = findChild(root, 'save')
            compare(saveButton.enable, False)
        }
    }
}
