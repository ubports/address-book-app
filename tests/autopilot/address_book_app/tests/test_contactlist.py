# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Mediaplayer App"""

from __future__ import absolute_import

from autopilot.matchers import Eventually
from testtools.matchers import Equals

from address_book_app.tests import AddressBookAppTestCase

import unittest
import time
import os
from os import path


class TestContactList(AddressBookAppTestCase):
    """Tests the contact list features"""

    """ This is needed to wait for the application to start.
        In the testfarm, the application may take some time to show up."""
    def setUp(self):
        super(TestContactList, self).setUp()
        self.launch_app()
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

    def tearDown(self):
        super(TestContactList, self).tearDown()

    """ Test if the toolbar appears """
    def test_toolbar_visibility(self):
        self.assertThat(
            self.main_window.get_qml_view().visible, Eventually(Equals(True)))

