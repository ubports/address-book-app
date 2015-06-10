# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the AddressBook App"""

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from address_book_app.tests import AddressBookAppTestCase


class TestExportContact(AddressBookAppTestCase):
    """Tests the erxport contact features"""

    PRELOAD_VCARD = True

    def test_export_contacts(self):
        contact_list = self.app.main_window.get_contact_list_page()

        # select one contact
        contact_list.select_contacts([1])

        # click on export header action
        self.app.main_window.click_action_button('share')

        # expect that the share page appears
        share_page = self.app.main_window.get_share_page()
        self.assertThat(share_page.active, Eventually(Equals(True)))
