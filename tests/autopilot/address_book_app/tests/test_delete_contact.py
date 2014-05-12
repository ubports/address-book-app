# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

"""Tests for the Addressbook App"""

# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from testtools.matchers import Equals
from address_book_app.tests import AddressBookAppTestCase


class TestDeleteSelectContact(AddressBookAppTestCase):
    """
    Delete a contact using pick mode and verify the behavior of Cancel and
    Delete actions
    """
    scenarios = [
        ("single_cancel", {
            "select": [1],
            "action": "cancel"}),
        ("multiple_cancel", {
            "select": [1, 2],
            "action": "cancel"}),
        ("single_delete", {
            "select": [1],
            "action": "delete"}),
        ("multiple_delete", {
            "select": [1, 2],
            "action": "delete"}),
    ]

    def setUp(self):
        AddressBookAppTestCase.PRELOAD_VCARD = True
        super(TestDeleteSelectContact, self).setUp()
    
    def test_select(self):
        """
        Delete a contact in pick mode

        This test switch the contact list view to pick mode and validate the
        behavior of Cancel and delete actions by comparing the numbers of
        contact in the list before and after the action.
        Note that it doesn't check which contact has been deleted.
        """
        listpage = self.main_window.get_contact_list_page()
        contacts_before = listpage.get_contacts()

        listpage.select_contacts_by_index(self.select)
        deleted = []
        if self.action == "cancel":
            self.main_window.cancel()
        elif self.action == "delete":
            listpage.delete(self.main_window)
            deleted = self.select

        contacts_after = listpage.get_contacts()
        # TODO:
        #   - Verify which contact have been deleted
        self.assertThat(len(contacts_after), Equals(len(contacts_before) -
                                                    len(deleted)))
