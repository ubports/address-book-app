# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import logging

from address_book_app.emulators.contact_list_page import ContactListPage
from address_book_app.emulators.toolbar import Toolbar
from autopilot import logging as autopilot_logging
from ubuntuuitoolkit import emulators as uitk

logger = logging.getLogger(__name__)


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
        return self.wait_select_single(ContactEditor,
                                       objectName="contactEditorPage")

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
        return self.wait_select_single( "ContactListView",
                                       objectName="contactListView")

    def get_button(self, name):
        """
        Returns a Button object matching 'name'

        Arguments:
            name: Name of the button
        """
        return self.wait_select_single( "Button", objectName=name)

    def cancel(self):
        """
        Press the 'Cancel' button
        """
        self.pointing_device.click_object(self.get_button("reject"))

    def save(self):
        """
        Press the 'Save' button
        """
        self.pointing_device.click_object(self.get_button("accept"))

    def get_toolbar(self):
        """Override base class so we get our expected Toolbar subclass."""
        return self.select_single(Toolbar)

    @autopilot_logging.log_action(logger.info)
    def go_to_add_contact(self):
        """
        Press the 'Add' button and return the contact editor page
        """
        toolbar = self.open_toolbar()
        toolbar.click_button(object_name="Add")
        return self.get_contact_edit_page()


class ContactEditor(uitk.UbuntuUIToolkitEmulatorBase):
    """Custom proxy object for the Contact Editor."""

    TEXT_FIELD_OBJECT_NAMES = {
        'first_name': 'firstName',
        'last_name': 'lastName'
    }

    @autopilot_logging.log_action(logger.info)
    def fill_form(self, contact_information):
        """Fill the edit contact form.

        :param contact_information: Values of the contact to fill the form.
        :type contact_information: dict
        :raises AddressBookAppError: If one of the keys doesn't correspond to
            any of the fields.

        """
        for field, value in contact_information.items():
            self._fill_field(field, value)

    def _fill_field(self, field, value):
        text_field = self._get_text_field(field)
        text_field.write(value)

    def _get_text_field(self, field):
        if field not in self.TEXT_FIELD_OBJECT_NAMES:
            raise AddressBookAppError('Unknown field: {}.'.format(field))

        object_name = self.TEXT_FIELD_OBJECT_NAMES[field]
        return self.select_single(TextInputDetail, objectName=object_name)

    def _get_form_values(self):
        information = dict()
        information['first_name'] = self._get_text_field('first_name').text
        information['last_name'] = self._get_text_field('last_name').text
        return information


class TextInputDetail(uitk.TextField):
    """Custom proxy object for the Text Input Detail field."""
