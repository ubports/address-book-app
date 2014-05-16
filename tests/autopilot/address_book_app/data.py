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


import uuid


class AddressBookAppDataError(Exception):
    """Exception raised when there is an error with the data."""


class DataMixin(object):
    """Mixin with common methods for data objects."""

    def __repr__(self):
        return '%s(%r)' % (self.__class__, self.__dict__)

    def __eq__(self, other):
        return (isinstance(other, self.__class__) and
                self.__dict__ == other.__dict__)

    def __ne__(self, other):
        return not self.__eq__(other)


class Phone(DataMixin):
    """Phone data object for user acceptance tests."""

    TYPES = ('Home', 'Work', 'Mobile', 'Work Mobile', 'Other')

    def __init__(self, type_, number):
        if type_ not in self.TYPES:
            raise AddressBookAppDataError(
                'Unknown phone type: {}.'.format(type_))
        self.type = type_
        self.number = number

    @classmethod
    def make(cls):
        """Return a Phone data object."""
        return cls(type_='Mobile', number='(818) 777-7755')


class Email(DataMixin):
    """Email data object for user acceptance tests."""

    TYPES = ('Home', 'Work', 'Other')

    def __init__(self, type_, address):
        if type_ not in self.TYPES:
            raise AddressBookAppDataError(
                'Unknown email type: {}.'.format(type_))
        self.type = type_
        self.address = address

    @classmethod
    def make_unique(cls, unique_id=None):
        """Return a unique Email data object."""
        if unique_id is None:
            unique_id = str(uuid.uuid1())
        type_ = 'Home'
        address = 'test+{0}@example.com'.format(unique_id)
        return cls(type_=type_, address=address)


class SocialAlias(DataMixin):
    """Social Alias data object for user acceptance tests."""

    TYPES = ('Aim', 'ICQ', 'Jabber', 'MSN', 'Skype', 'Yahoo')

    def __init__(self, type_, alias):
        if type_ not in self.TYPES:
            raise AddressBookAppDataError(
                'Unknown social alias type: {}.'.format(type_))
        self.type = type_
        self.alias = alias

    @classmethod
    def make_unique(cls, unique_id=None):
        """Return a unique Social Alias data object."""
        if unique_id is None:
            unique_id = str(uuid.uuid1())
        type_ = 'Skype'
        alias = 'Test alias {}'.format(unique_id)
        return cls(type_=type_, alias=alias)


class Address(DataMixin):
    """Address data object for user acceptance tests."""

    TYPES = ('Home', 'Work', 'Other')

    def __init__(self, type_, street, locality, region, postal_code, country):
        if type_ not in self.TYPES:
            raise AddressBookAppDataError(
                'Unknown address type: {}.'.format(type_))
        self.type = type_
        self.street = street
        self.locality = locality
        self.region = region
        self.postal_code = postal_code
        self.country = country

    @classmethod
    def make_unique(cls, unique_id=None):
        """Return a unique address data object."""
        if unique_id is None:
            unique_id = str(uuid.uuid1())
        type_ = 'Home'
        street = 'Test street {}'.format(unique_id)
        locality = 'Test locality {}'.format(unique_id)
        region = 'Test region {}'.format(unique_id)
        postal_code = 'Test postal code {}'.format(unique_id)
        country = 'Test country {}'.format(unique_id)
        return cls(
            type_=type_, street=street, locality=locality, region=region,
            postal_code=postal_code, country=country)


class ProfessionalDetails(DataMixin):
    """Professional Details data objects for user acceptance tests."""

    def __init__(self, organization, role, title):
        self.organization = organization
        self.role = role
        self.title = title

    @classmethod
    def make_unique(cls, unique_id=None):
        """Return a unique data object with Professional Details."""
        if unique_id is None:
            unique_id = str(uuid.uuid1())
        organization = 'Test organization {}'.format(unique_id)
        role = 'Test role {}'.format(unique_id)
        title = 'Test title {}'.format(unique_id)
        return cls(organization=organization, role=role, title=title)


class Contact(DataMixin):
    """Contact data object for user acceptance tests."""

    def __init__(
            self, first_name=None, last_name=None, phones=None, emails=None,
            social_aliases=None, addresses=None, professional_details=None):
        self.first_name = first_name
        self.last_name = last_name
        self.phones = phones
        self.emails = emails
        self.social_aliases = social_aliases
        self.addresses = addresses
        self.professional_details = professional_details

    @classmethod
    def make_unique(cls, unique_id=None):
        """Return a unique Contact data object."""
        if unique_id is None:
            unique_id = str(uuid.uuid1())
        first_name = 'Test first name {}'.format(unique_id)
        last_name = 'Test last name {}'.format(unique_id)
        phone = Phone.make()
        email = Email.make_unique(unique_id)
        social_alias = SocialAlias.make_unique(unique_id)
        address = Address.make_unique(unique_id)
        professional_details = ProfessionalDetails.make_unique(unique_id)
        return cls(
            first_name=first_name, last_name=last_name, phones=[phone],
            emails=[email], social_aliases=[social_alias],
            addresses=[address], professional_details=[professional_details])
