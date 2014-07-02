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
        useDeprecatedToolbar: false

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
       ];

        var newContact = Qt.createQmlObject(
            'import QtContacts 5.0; Contact{ }', mainView);
        var detailSourceTemplate = 'import QtContacts 5.0; %1{ %2: "%3" }';
        for (var i=0; i < details.length; i++) {
            var detailMetaData = details[i];
            var template = detailSourceTemplate.arg(detailMetaData.detail).arg(
                detailMetaData.field).arg(detailMetaData.value);
            var newDetail = Qt.createQmlObject(template, mainView);
            newContact.addDetail(newDetail);
        }
        return newContact;
    }

    UbuntuTestCase {
        id: contactEditorTestCase
        name: 'contactEditorTestCase'

        when: windowShown

        function init() {
            waitForRendering(contactEditor);
            var saveButton = findChild(root, 'save_header_button');
            compare(saveButton.enabled, false);
        }

        function cleanup() {
            var textFields = getRequiredTextFields().concat(
                getOptionalTextFields());
            textFields.forEach(clearTextField);
        }

        function getRequiredTextFields() {
            return ['firstName', 'lastName', 'phoneNumber_0'];
        }

        function getOptionalTextFields() {
            return [
                'emailAddress_0', 'imUri_0', 'streetAddress_0',
                'localityAddress_0', 'regionAddress_0', 'postcodeAddress_0',
                'countryAddress_0', 'orgName_0', 'orgRole_0', 'orgTitle_0'
            ];
        }

        function clearTextField(value, index, array) {
            var textField = findChild(root, value);
            textField.text = '';
        }

        function test_fillRequiredFieldsMustEnableSaveButton_data() {
            var textFields = getRequiredTextFields();
            return objectNamesArrayToDataScenarios(textFields);
        }

        function objectNamesArrayToDataScenarios(objectNamesArray) {
            var data = [];
            for (var index = 0; index < objectNamesArray.length; index++) {
                var objectName = objectNamesArray[index];
                data.push({tag: objectName, objectName: objectName});
            }
            return data;
        }

        function test_fillRequiredFieldsMustEnableSaveButton(data) {
            var textField = findChild(root, data.objectName);
            textField.text = 'test'
            var saveButton = findChild(root, 'save_header_button');
            tryCompare(saveButton, 'enabled', true);
        }

        function test_fillOptionalFieldsMustNotEnableSaveButton_data() {
            var textFields = getOptionalTextFields();
            return objectNamesArrayToDataScenarios(textFields)
        }

        function test_fillOptionalFieldsMustNotEnableSaveButton(data) {
            var textField = findChild(root, data.objectName);
            textField.text = 'test'
            var saveButton = findChild(root, 'save_header_button');
            tryCompare(saveButton, 'enabled', false);
        }
    }
}
