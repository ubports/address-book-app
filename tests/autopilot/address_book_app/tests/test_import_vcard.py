# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2015 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from __future__ import absolute_import
from testtools.matchers import Equals
from autopilot.matchers import Eventually
import os

from address_book_app.tests import AddressBookAppTestCase


class TeseImportVCard(AddressBookAppTestCase):
    """Tests import vcard"""

    def setUp(self):
        vcard_path = AddressBookAppTestCase.VCARD_PATH_DEV
        if os.path.exists(AddressBookAppTestCase.VCARD_PATH_BIN):
            vcard_path = AddressBookAppTestCase.VCARD_PATH_BIN

        self.ARGS.append("addressbook:///importvcard?url=file://%s" % vcard_path)
        super(TeseImportVCard, self).setUp()

    def test_import_vcard_results(self):
        # check if app enter on import state
        list_page = self.app.main_window.get_contact_list_page()
        self.assertThat(list_page.state, Eventually(Equals('vcardImported')))
        self.assertThat(list_page.title, Eventually(Equals('Imported contacts')))
        self.assertThat(len(list_page.get_contacts()), Equals(3))

        #leave import state and show full contact list
        self.app.main_window.cancel()
        self.assertThat(list_page.state, Eventually(Equals('default')))
        self.assertThat(list_page.title, Eventually(Equals('Contacts')))
