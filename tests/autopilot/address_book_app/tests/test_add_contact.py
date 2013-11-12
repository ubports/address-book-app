# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from __future__ import absolute_import

from address_book_app.tests import AddressBookAppTestCase

import unittest
import time
import os
from os import path

class TestAddContact(AddressBookAppTestCase):
    """Tests the Add contact"""

    def test_add_contact_with_name(self):
        toolbar = self.main_window.get_toolbar()
        toolbar.open()
        toolbar.click_button("Add")        
