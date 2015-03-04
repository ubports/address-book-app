# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from testtools.matchers import Equals
from testtools import skipUnless

from autopilot.matchers import Eventually

from address_book_app import data
from address_book_app.tests import AddressBookAppTestCase
from address_book_app import helpers

@skipUnless(helpers.is_phonesim_running(),
            "this test needs to run under with-ofono-phonesim")
class TestImportFromSimContact(AddressBookAppTestCase):
    """Tests import a contact from sim card"""

    def test_impot_item_is_visible_on_the_list(self):
        # contact list is empty
        list_page = self.app.main_window.get_contact_list_page()
        self.assertThat(len(list_page.get_contacts()), Equals(0))

        # button should be visible if list is empty
        import_from_sim_button = self.app.main_window.select_single(
            'ContactListButtonDelegate',
            objectName='contactListView.importFromSimCardButton')
        self.assertThat(import_from_sim_button.visible, Eventually(Equals(True)))

        # add a new contact
        self.add_contact("Fulano", "de Tal", [self.PHONE_NUMBERS[0]])

        # button should be invisible if list is not empty
        self.assertThat(import_from_sim_button.visible, Eventually(Equals(False)))
       
    def test_import_from_sim(self):
        list_page = self.app.main_window.get_contact_list_page()
        import_page = self.app.main_window.start_import_contacts()

        # contact list is empty
        self.assertThat(len(list_page.get_contacts()), Equals(0))

        # import two contacts
        contacts = import_page.select_contacts([1,3])
        self.assertThat(len(contacts), Equals(2))
        self.app.main_window.confirm_import()

        # verify if the contact was imported
        new_contacts = list_page.get_contacts()
        self.assertThat(len(new_contacts), Equals(2))
        for contact in new_contacts:
            contacts.remove(contact)
        self.assertThat(len(contacts), Equals(0))

