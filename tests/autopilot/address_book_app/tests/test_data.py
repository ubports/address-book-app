# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2014 Canonical
#
# This file is part of address-book-app
#
# address-book-app is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import testtools
import testscenarios
from testtools.matchers import HasLength

from address_book_app import data


class PhoneTypesTestCase(testscenarios.TestWithScenarios, testtools.TestCase):

    valid_types = ['Home', 'Work', 'Mobile', 'Work Mobile', 'Other']
    scenarios = [(type_, dict(type=type_)) for type_ in valid_types]

    def test_make_phone_with_valid_type(self):
        """Test that we can create a phone data object with a valid type."""
        phone = data.Phone(type_=self.type, number='dummy')

        self.assertEqual(phone.type, self.type)


class MakePhoneTestCase(testtools.TestCase):

    def test_make_phone(self):
        """Test that we can create a phone data object with default values."""
        phone = data.Phone.make()

        self.assertEqual(phone.type, 'Mobile')
        self.assertEqual(phone.number, '123')

    def test_make_phone_with_unknown_type(self):
        """Test the error when we try to create a phone with a wrong type."""
        error = self.assertRaises(
            data.AddressBookAppDataError, data.Phone, type_='unknown',
            number='dummy')

        self.assertEqual('Unknown phone type: unknown.', str(error))


class EmailTypesTestCase(testscenarios.TestWithScenarios, testtools.TestCase):

    valid_types = ['Home', 'Work', 'Other']
    scenarios = [(type_, dict(type=type_)) for type_ in valid_types]

    def test_make_email_with_valid_type(self):
        """Test that we can create an email data object with a valid type."""
        email = data.Email(type_=self.type, address='dummy')

        self.assertEqual(email.type, self.type)


class MakeEmailTestCase(testtools.TestCase):

    def test_make_unique_email(self):
        """Test that we can create an email data object with default values."""
        email = data.Email.make_unique(unique_id='test_uuid')

        self.assertEqual(email.address, 'test+test_uuid@example.com')

    def test_make_email_with_unknown_type(self):
        """Test the error when we try to create an email with a wrong type."""
        error = self.assertRaises(
            data.AddressBookAppDataError, data.Email, type_='unknown',
            address='dummy')

        self.assertEqual('Unknown email type: unknown.', str(error))


class SocialAliasTypesTestCase(
        testscenarios.TestWithScenarios, testtools.TestCase):

    valid_types = ['Yahoo', 'Aim', 'ICQ', 'Jabber', 'MSN', 'Skype', 'Yahoo']
    scenarios = [(type_, dict(type=type_)) for type_ in valid_types]

    def test_make_social_alias_with_valid_type(self):
        """Test that we can create a social alias object with a valid type."""
        social_alias = data.SocialAlias(type_=self.type, alias='dummy')

        self.assertEqual(social_alias.type, self.type)


class MakeSocialAliasTestCase(testtools.TestCase):

    def test_make_unique_social_alias(self):
        """Test that we can create a social alias with default values."""
        social_alias = data.SocialAlias.make_unique(unique_id='test_uuid')

        self.assertEqual(social_alias.alias, 'Test alias test_uuid')

    def test_make_social_alias_with_unknown_type(self):
        """Test the error when we create a social alias with a wrong type."""
        error = self.assertRaises(
            data.AddressBookAppDataError, data.SocialAlias, type_='unknown',
            alias='dummy')

        self.assertEqual('Unknown social alias type: unknown.', str(error))


class AddressTypesTestCase(
        testscenarios.TestWithScenarios, testtools.TestCase):

    valid_types = ['Home', 'Work', 'Other']
    scenarios = [(type_, dict(type=type_)) for type_ in valid_types]

    def test_make_address_with_valid_type(self):
        """Test that we can create an address data object with a valid type."""
        address = data.Address(
            type_=self.type, street='dummy', locality='dummy', region='dummy',
            postal_code='dummy', country='dummy')

        self.assertEqual(address.type, self.type)


class MakeAddressTestCase(testtools.TestCase):

    def test_make_unique_address(self):
        """Test that we can create an address object with default values."""
        address = data.Address.make_unique(unique_id='test_uuid')

        self.assertEqual(address.street, 'Test street test_uuid')
        self.assertEqual(address.locality, 'Test locality test_uuid')
        self.assertEqual(address.region, 'Test region test_uuid')
        self.assertEqual(address.postal_code, 'Test postal code test_uuid')
        self.assertEqual(address.country, 'Test country test_uuid')

    def test_make_address_with_unknown_type(self):
        """Test the error when we create an address with a wrong type."""
        error = self.assertRaises(
            data.AddressBookAppDataError, data.Address, type_='unknown',
            street='dummy', locality='dummy', region='dummy',
            postal_code='dummy', country='dummy')

        self.assertEqual('Unknown address type: unknown.', str(error))


class MakeProfessionalDetailsTestCase(testtools.TestCase):

    def test_make_unique_professional_details(self):
        """Test that we can create professiona details with default values."""
        professional_details = data.ProfessionalDetails.make_unique(
            unique_id='test_uuid')

        self.assertEqual(
            professional_details.organization, 'Test organization test_uuid')
        self.assertEqual(
            professional_details.role, 'Test role test_uuid')
        self.assertEqual(
            professional_details.title, 'Test title test_uuid')


class ContactTestCase(testtools.TestCase):

    def test_make_unique_contact(self):
        contact = data.Contact.make_unique(unique_id='test_uuid')

        self.assertEqual(contact.first_name, 'Test first name test_uuid')
        self.assertEqual(contact.last_name, 'Test last name test_uuid')
        self.assertThat(contact.phones, HasLength(1))
        self.assertIsInstance(contact.phones[0], data.Phone)
        self.assertThat(contact.emails, HasLength(1))
        self.assertIsInstance(contact.emails[0], data.Email)
        self.assertThat(contact.social_aliases, HasLength(1))
        self.assertIsInstance(contact.social_aliases[0], data.SocialAlias)
        self.assertThat(contact.addresses, HasLength(1))
        self.assertIsInstance(contact.addresses[0], data.Address)
        self.assertThat(contact.professional_details, HasLength(1))
        self.assertIsInstance(
            contact.professional_details[0], data.ProfessionalDetails)
