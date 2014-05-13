# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import collections
import logging
import time

from autopilot import logging as autopilot_logging
from autopilot.introspection.dbus import StateNotFoundError
from ubuntuuitoolkit import emulators as uitk

from address_book_app import data
from address_book_app.emulators.page_with_bottom_edge import ContactListPage


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
        raise AddressBookAppError('Unknown field: {}.'.format(field))

    object_name = _TEXT_FIELD_OBJECT_NAMES[field]
    if index is not None:
        object_name = object_name.format(index)
    return parent.select_single(TextInputDetail, objectName=object_name)


class AddressBookAppError(uitk.ToolkitEmulatorException):
    """Exception raised when there is an error with the emulator."""


class MainWindow(uitk.MainView):
    """An emulator class that makes it easy to interact with the app."""

    def get_contact_list_page(self):
        # ContactListPage is the only page that can appears multiple times
        # Ex.: During the pick mode we alway push a new contactListPage, to
        # preserve the current application status.
        pages = self.select_many(ContactListPage,
                                 objectName="contactListPage")

        # alway return the page without pickMode
        for p in pages:
            if not p.pickMode:
                return p
        return None

    def get_contact_edit_page(self):
        # We can have two contact editor page because of bottom edge page
        # but we will return only the actived one
        list_page = self.get_contact_list_page()
        list_page.bottomEdgePageLoaded.wait_for(True)
        if not list_page.isReady:
            raise StateNotFoundError('contactEditorPage not ready')
            
        pages = self.select_many(ContactEditor,
                                 objectName="contactEditorPage")
        for p in pages:
            if p.active:
                return p
        raise StateNotFoundError('contactEditorPage not found')
        return None


    def get_contact_view_page(self):
        return self.wait_select_single("ContactView",
                                       objectName="contactViewPage")

    def get_contact_list_pick_page(self):
        pages = self.select_many("ContactListPage",
                                 objectName="contactListPage")
        for p in pages:
            if p.pickMode:
                return p
        return None

    def get_contact_list_view(self):
        """
        Returns a ContactListView iobject for the current window
        """
        return self.wait_select_single("ContactListView",
                                       objectName="contactListView")

    def get_button(self, buttonName):
        return self.get_header()._get_action_button(buttonName)

    def open_header(self):
        header = self.get_header()
        if (header.y != 0):
            edit_page = self.get_contact_edit_page()
            flickable = edit_page.wait_select_single(
                "QQuickFlickable",
                objectName="scrollArea")
            
            while (header.y != 0):
                globalRect = flickable.globalRect
                start_x = globalRect.x + (globalRect.width * 0.5)
                start_y = globalRect.y + (flickable.height * 0.1)
                stop_y = start_y + (flickable.height * 0.1)

                self.pointing_device.drag(start_x, start_y, start_x, stop_y, rate=5)
                # wait flicking stops to move to the next field
                flickable.flicking.wait_for(False)

        return header

    def cancel(self):
        """
        Press the 'Cancel' button
        """
        header = self.open_header()
        header.click_custom_back_button()

    def save(self):
        """
        Press the 'Save' button
        """        
        bottom_swipe_page = self.get_contact_list_page()
        self.click_action_button("save")
        bottom_swipe_page.isCollapsed.wait_for(True)

    def done_selection(self):
        """
        Press the 'doneSelection' button
        """        
        bottom_swipe_page = self.get_contact_list_page()
        self.click_action_button("doneSelection")
        bottom_swipe_page.isCollapsed.wait_for(True)

    @autopilot_logging.log_action(logger.info)
    def go_to_add_contact(self):
        """
        Press the 'Add' button and return the contact editor page
        """
        bottom_swipe_page = self.get_contact_list_page()
        bottom_swipe_page.revel_bottom_edge_page()
        return self.get_contact_edit_page()


class ContactEditor(uitk.UbuntuUIToolkitEmulatorBase):
    """Custom proxy object for the Contact Editor."""

    @autopilot_logging.log_action(logger.info)
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
        editor.fill(details)

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


class TextInputDetail(uitk.TextField):
    """Custom proxy object for the Text Input Detail field."""


class ContactDetailGroupWithTypeEditor(uitk.UbuntuUIToolkitEmulatorBase):
    """Custom proxy object for the ContactDetailGroupWithTypeEditor widget."""

    _DETAIL_EDITORS = {
        'phones': 'base_phoneNumber_{}',
        'emails': 'base_email_{}',
        'ims': 'base_onlineAccount_{}',
        'addresses': 'base_address_{}',
        # FIXME fix the unknown. --elopio - 2014-03-01
        'professionalDetails': 'base_unknown_{}'
    }

    def fill(self, details):
        """Fill a contact detail group."""
        for index, detail in enumerate(details[:-1]):
            self._fill_detail(index, detail)
            self._add_detail()
        self._fill_detail(len(details) - 1, details[-1])

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


class ContactDetailWithTypeEditor(uitk.UbuntuUIToolkitEmulatorBase):
    """Custom proxy object for the ContactDetailWithTypeEditor widget."""

    def __init__(self, *args):
        super(ContactDetailWithTypeEditor, self).__init__(*args)
        self.main_view = self.get_root_instance().select_single(MainWindow)

    def fill(self, field, index, detail):
        self._select_type(detail)
        self._fill_value(field, index, detail)

    def _select_type(self, detail):
        type_index = detail.TYPES.index(detail.type)
        selected_type_index = self._get_selected_type_index()
        if type_index != selected_type_index:
            # TODO --elopio - 2014-03-01
            raise NotImplementedError('Type selection not yet implemented.')

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
            raise AddressBookAppError('Unknown field: {}.'.format(field))

    def _fill_single_field(self, value):
        text_field = self.select_single(TextInputDetail)
        self._make_field_visible_and_write(text_field, value)

    def _make_field_visible_and_write(self, text_field, value):
        while not text_field.activeFocus:
            # XXX We should just swipe the text field into view.
            # Update this once bug http://pad.lv/1286479 is implemented.
            # --elopio - 2014-03-01
            text_field.keyboard.press_and_release('Tab')
            time.sleep(0.1)
            self.main_view.get_contact_edit_page().wait_to_stop_moving()

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
        raise AddressBookAppError('Unknown field: {}.'.format(field))

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
