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
import Ubuntu.Test 0.1
import QtContacts 5.0

import Ubuntu.Components 1.1
import Ubuntu.Contacts 0.1
import Ubuntu.AddressBook.ContactView 0.1

import "ContactUtil.js" as ContactUtilJS

Item {
    id: root

    function createContactWithName() {
        var details = [
           {detail: 'Name', field: 'firstName', value: 'Fulano'},
        ];
        return ContactUtilJS.createContact(details, root)
    }

    function createContactWithNameAndAvatar() {
        var details = [
           {detail: 'Name', field: 'firstName', value: 'Fulano'},
           {detail: 'Avatar', field: 'imageUrl', value: 'image://theme/address-book-app'}
        ];
        return ContactUtilJS.createContact(details, root)
    }

    VCardParser {
        id: vcardParser

        vCardUrl: Qt.resolvedUrl("../data/vcard_single.vcf")
    }


    width: units.gu(40)
    height: units.gu(80)

    MainView {
        id: mainView
        anchors.fill: parent
        useDeprecatedToolbar: false

        ContactViewPage {
            id: contactPreviewPage
            anchors.fill: parent
        }
    }


    UbuntuTestCase {
        id: contactPreviewPageTestCase
        name: 'contactPreviewPageTestCase'

        when: windowShown

        function findChildOfType(obj, typeName) {
            var childs = new Array(0)
            var result = new Array(0)
            childs.push(obj)
            while (childs.length > 0) {
                var objTypeName = String(childs[0]).split("_")[0]
                if (objTypeName === typeName) {
                    result.push(childs[0])
                }
                for (var i in childs[0].children) {
                    childs.push(childs[0].children[i])
                }
                childs.splice(0, 1)
            }
            return result
        }


        function init()
        {
            waitForRendering(mainView);
            contactPreviewPage.contact = null
        }

        function test_preview_contact_with_name()
        {
            contactPreviewPage.contact = createContactWithName()
            tryCompare(contactPreviewPage, "title", "Fulano")
        }

        function test_preview_contact_with_name_and_avatar()
        {
            contactPreviewPage.contact = createContactWithNameAndAvatar()
            tryCompare(contactPreviewPage, "title", "Fulano")
            var avatarField = findChild(root, "contactAvatarDetail")
            tryCompare(avatarField, "avatarUrl", "image://theme/address-book-app")
        }

        function test_preview_with_full_contact()
        {
            compare(vcardParser.contacts.length, 1)
            var contact =  vcardParser.contacts[0]
            console.debug("Contact: " + contact.phoneNumber.number)
            contactPreviewPage.contact = contact
            tryCompare(contactPreviewPage, "title", "Forrest Gump")
            // PhoneNumbers
            // TEL;TYPE=WORK,VOICE:(111) 555-12121
            // TEL;TYPE=HOME,VOICE:(404) 555-1212

            // number of phones
            var phoneNumberGroup = findChild(root, "phones")
            var phoneNumbers = findChildOfType(phoneNumberGroup, "BasicFieldView")
            compare(phoneNumbers.length, 2)

            // first phone
            var phoneNumber = findChild(phoneNumberGroup, "label_phoneNumber_0.0")
            var phoneNumberType =  findChild(phoneNumberGroup, "type_phoneNumber_0")
            compare(phoneNumber.text, "(111) 555-12121")
            compare(phoneNumberType.text, "Work")

            // second phone
            phoneNumber = findChild(phoneNumberGroup, "label_phoneNumber_1.0")
            phoneNumberType =  findChild(phoneNumberGroup, "type_phoneNumber_1")
            compare(phoneNumber.text, "(404) 555-1212")
            compare(phoneNumberType.text, "Home")

            // E-mails
            // EMAIL;TYPE=PREF,INTERNET:forrestgump@example.com

            // number of e-mails
            var emailGroup = findChild(root, "emails")
            var emails = findChildOfType(emailGroup, "BasicFieldView")
            compare(emails.length, 1)

            // e-mail address
            var email = findChild(emailGroup, "label_emailAddress_0.0")
            var emailType =  findChild(emailGroup, "type_email_0")
            compare(email.text, "forrestgump@example.com")
            compare(emailType.text, "Home")

            // Address
            // ADR;TYPE=WORK:;;100 Waters Edge;Baytown;LA;30314;United States of America
            // ADR;TYPE=HOME:;;42 Plantation St.;Baytown;LA;30314;United States of America

            // number of addresses
            var addressGroup = findChild(root, "addresses")
            var addresses = findChildOfType(addressGroup, "BasicFieldView")
            compare(addresses.length, 2)

            // first address
            var address_street = findChild(addressGroup, "label_streetAddress_0.0")
            var address_locality = findChild(addressGroup, "label_localityAddress_0.1")
            var address_region = findChild(addressGroup, "label_regionAddress_0.2")
            var address_postCode = findChild(addressGroup, "label_postcodeAddress_0.3")
            var address_country = findChild(addressGroup, "label_countryAddress_0.4")
            var address_type =  findChild(addressGroup, "type_address_0")
            compare(address_street.text, "100 Waters Edge")
            compare(address_locality.text, "Baytown")
            compare(address_region.text, "LA")
            compare(address_postCode.text, "30314")
            compare(address_country.text, "United States of America")
            compare(address_type.text, "Work")

            // second address
            address_street = findChild(addressGroup, "label_streetAddress_1.0")
            address_locality = findChild(addressGroup, "label_localityAddress_1.1")
            address_region = findChild(addressGroup, "label_regionAddress_1.2")
            address_postCode = findChild(addressGroup, "label_postcodeAddress_1.3")
            address_country = findChild(addressGroup, "label_countryAddress_1.4")
            address_type =  findChild(addressGroup, "type_address_1")
            compare(address_street.text, "42 Plantation St.")
            compare(address_locality.text, "Baytown")
            compare(address_region.text, "LA")
            compare(address_postCode.text, "30314")
            compare(address_country.text, "United States of America")
            compare(address_type.text, "Home")

            // Organization
            // ORG:Bubba Gump Shrimp Co.
            // TITLE:Shrimp Man

            // number of organizations
            var orgGroup = findChild(root, "organizations")
            var orgs = findChildOfType(orgGroup, "BasicFieldView")
            compare(orgs.length, 1)

            var org_name = findChild(orgGroup, "label_orgName_0.0")
            var org_role = findChild(orgGroup, "label_orgRole_0.1")
            var org_title = findChild(orgGroup, "label_orgTitle_0.2")

            compare(org_name.text, "Bubba Gump Shrimp Co.")
            compare(org_role.text, "")
            compare(org_title.text, "Shrimp Man")
        }
    }
}

