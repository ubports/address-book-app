# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import collections
import logging
import time

import autopilot.logging
import ubuntuuitoolkit
from address_book_app.address_book import data, _errors, _common


logger = logging.getLogger(__name__)


_TEXT_FIELD_OBJECT_NAMES = {
    'first_name': 'firstName',
    'last_name': 'lastName',
    'street': 'streetAddress_{}',
    'locality': 'localityAddress_{}',
    'region': 'regionAddress_{}',
    'postal_code': 'postcodeAddress_{}',
    'country': 'countryAddress_{}'
}


def _get_text_field(parent, field, index=None):
    if field not in _TEXT_FIELD_OBJECT_NAMES:
        raise _errors.AddressBookAppError('Unknown field: {}.'.format(field))

    object_name = _TEXT_FIELD_OBJECT_NAMES[field]
    if index is not None:
        object_name = object_name.format(index)
    return parent.select_single(TextInputDetail, objectName=object_name)


class ContactEditorPage(_common.PageWithHeader):
    """Custom proxy object for the Contact Editor."""

    _DETAIL_ALIAS = {
        'phones': 'Phone',
        'emails': 'Email',
        'ims': 'Social',
        'addresses': 'Address',
        'professionalDetails': 'Professional Details'
    }

    @autopilot.logging.log_action(logger.info)
    def add_field(self, detail_name):
        """Create a new field into the edit contact form.

        :param detail_name: The detail field name

        """

        add_field_button = self.select_single(
            'ComboButtonAddField', objectName='addNewFieldButton')
        add_field_button.swipe_into_view()

        self.pointing_device.click_object(add_field_button)
        add_field_button.height.wait_for(add_field_button.expandedHeight)
        self.wait_to_stop_moving()

        options_list = add_field_button.select_single(
            "QQuickListView",
            objectName="listViewOptions")
        new_field_item = options_list.select_single(
            "Standard",
            objectName=self._DETAIL_ALIAS[detail_name])
        new_field_item.swipe_into_view()

        self.pointing_device.click_object(new_field_item)
        add_field_button.height.wait_for(add_field_button.collapsedHeight)

    @autopilot.logging.log_action(logger.info)
    def fill_form(self, contact_information):
        """Fill the edit contact form.

        :param contact_information: Values of the contact to fill the form.
        :type contact_information: data object with the attributes first_name,
            last_name, phones, emails, social_aliases, addresses and
             professional_details

        """
        if contact_information.first_name is not None:
            self._fill_first_name(contact_information.first_name)
        if contact_information.last_name is not None:
            self._fill_last_name(contact_information.last_name)

        groups = collections.OrderedDict()
        groups['phones'] = contact_information.phones
        groups['emails'] = contact_information.emails
        groups['ims'] = contact_information.social_aliases
        groups['addresses'] = contact_information.addresses
        groups['professionalDetails'] = (
            contact_information.professional_details)

        for key, information in groups.items():
            if information:
                self._fill_detail_group(
                    object_name=key, details=information)

    def _fill_first_name(self, first_name):
        text_field = _get_text_field(self, 'first_name')
        text_field.write(first_name)

    def _fill_last_name(self, last_name):
        text_field = _get_text_field(self, 'last_name')
        text_field.write(last_name)

    def _fill_detail_group(self, object_name, details):
        editor = self.select_single(
            ContactDetailGroupWithTypeEditor, objectName=object_name)
        editor.fill(self, details)

    def _get_form_values(self):
        first_name = _get_text_field(self, 'first_name').text
        last_name = _get_text_field(self, 'last_name').text
        phones = self._get_values_from_detail_group(object_name='phones')
        emails = self._get_values_from_detail_group(object_name='emails')
        social_aliases = self._get_values_from_detail_group(object_name='ims')
        addresses = self._get_values_from_detail_group(object_name='addresses')
        professional_details = self._get_values_from_detail_group(
            object_name='professionalDetails')

        return data.Contact(
            first_name=first_name, last_name=last_name, phones=phones,
            emails=emails, social_aliases=social_aliases, addresses=addresses,
            professional_details=professional_details)

    def _get_values_from_detail_group(self, object_name):
        editor = self.select_single(
            ContactDetailGroupWithTypeEditor, objectName=object_name)
        return editor.get_values(object_name)

    def wait_to_stop_moving(self):
        flickable = self.select_single(
            'QQuickFlickable', objectName='scrollArea')
        flickable.flicking.wait_for(False)

    def wait_get_focus(self, section_name):
        editor = self.select_single(
            ContactDetailGroupWithTypeEditor, objectName=section_name)
        editor.activeFocus.wait_for(True)


class TextInputDetail(ubuntuuitoolkit.TextField):
    """Custom proxy object for the Text Input Detail field."""


class ContactDetailGroupWithTypeEditor(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """Custom proxy object for the ContactDetailGroupWithTypeEditor widget."""

    _DETAIL_EDITORS = {
        'phones': 'base_phoneNumber_{}',
        'emails': 'base_email_{}',
        'ims': 'base_onlineAccount_{}',
        'addresses': 'base_address_{}',
        # FIXME fix the unknown. --elopio - 2014-03-01
        'professionalDetails': 'base_unknown_{}'
    }

    def fill(self, editor, details):
        """Fill a contact detail group."""
        for index, detail in enumerate(details):
            if self.detailsCount <= index:
                editor.add_field(self.objectName)
            self._fill_detail(index, detail)

    def _fill_detail(self, index, detail):
        detail_editor = self._get_detail_editor_by_index(index)
        detail_editor.fill(field=self.objectName, index=index, detail=detail)

    def _get_detail_editor_by_index(self, index):
        object_name = self._get_contact_detail_editor_object_name(index)
        return self.select_single(
            ContactDetailWithTypeEditor, objectName=object_name)

    def _get_contact_detail_editor_object_name(self, index):
        return self._DETAIL_EDITORS[self.objectName].format(index)

    def _add_detail(self):
        # TODO --elopio - 2014-03-01
        raise NotImplementedError('Add extra details not yet implemented.')

    def get_values(self, object_name):
        """Return the values of a contact detail group."""
        values = []
        for index in range(self.detailsCount):
            detail_editor = self._get_detail_editor_by_index(index)
            value = detail_editor.get_values(field=object_name, index=index)
            if (value):
                values.append(value)

        return values


class ContactDetailWithTypeEditor(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """Custom proxy object for the ContactDetailWithTypeEditor widget."""

    def fill(self, field, index, detail):
        self._fill_value(field, index, detail)
        self._select_type(detail)

    def _select_type(self, detail):
        type_index = detail.TYPES.index(detail.type)
        value_selector = self.select_single('ValueSelector')

        while(value_selector.currentIndex != type_index):
            ubuntuuitoolkit.get_keyboard().press_and_release("Shift+Right")
            time.sleep(0.1)

    def _get_selected_type_index(self):
        value_selector = self.select_single('ValueSelector')
        return value_selector.currentIndex

    def _fill_value(self, field, index, detail):
        single_values = {
            'phones': 'number',
            'emails': 'address',
            'ims': 'alias'
        }
        if field in single_values:
            self._fill_single_field(getattr(detail, single_values[field]))
        elif field == 'addresses':
            self._fill_address(index, detail)
        elif field == 'professionalDetails':
            self._fill_professional_details(index, detail)
        else:
            raise _errors.AddressBookAppError(
                'Unknown field: {}.'.format(field))

    def _fill_single_field(self, value):
        text_field = self.select_single(TextInputDetail)
        self._make_field_visible_and_write(text_field, value)

    def _make_field_visible_and_write(self, text_field, value):
        text_field.swipe_into_view()
        text_field.write(value)

    def _fill_address(self, index, address):
        fields = collections.OrderedDict()
        fields['street'] = address.street
        fields['locality'] = address.locality
        fields['region'] = address.region
        fields['postal_code'] = address.postal_code
        fields['country'] = address.country
        for key, value in fields.items():
            text_field = _get_text_field(self, key, index)
            self._make_field_visible_and_write(text_field, value)

    def _fill_professional_details(self, index, address):
        # TODO --elopio - 2014-03-01
        raise NotImplementedError('Not yet implemented.')

    def get_values(self, field, index):
        if field == 'phones':
            return data.Phone(
                type_=data.Phone.TYPES[self._get_selected_type_index()],
                number=self._get_single_field_value())
        if field == 'emails':
            return data.Email(
                type_=data.Email.TYPES[self._get_selected_type_index()],
                address=self._get_single_field_value())
        if field == 'ims':
            return data.SocialAlias(
                type_=data.SocialAlias.TYPES[self._get_selected_type_index()],
                alias=self._get_single_field_value())
        if field == 'addresses':
            return self._get_address_value(index)
        if field == 'professionalDetails':
            # TODO --elopio - 2014-03-01
            return None
        raise _errors.AddressBookAppError('Unknown field: {}.'.format(field))

    def _get_single_field_value(self):
        return self.select_single(TextInputDetail).text

    def _get_address_value(self, index):
        street = _get_text_field(self, 'street', index).text
        locality = _get_text_field(self, 'locality', index).text
        region = _get_text_field(self, 'region', index).text
        postal_code = _get_text_field(self, 'postal_code', index).text
        country = _get_text_field(self, 'country', index).text
        return data.Address(
            type_=data.Address.TYPES[self._get_selected_type_index()],
            street=street, locality=locality, region=region,
            postal_code=postal_code, country=country)
