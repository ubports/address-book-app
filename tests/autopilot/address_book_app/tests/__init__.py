# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2012 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""address-book-app autopilot tests."""

from os import remove
import os.path
import os

from autopilot.input import Mouse, Touch, Pointer
from autopilot.platform import model
from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from testtools.matchers import Equals

from address_book_app.emulators.main_window import MainWindow


class AddressBookAppTestCase(AutopilotTestCase):
    """A common test case class that provides several useful methods for
    address-book-app tests.

    """
    DEFAULT_DEV_LOCATION = "../../src/app/address-book-app"

    if model() == 'Desktop':
        scenarios = [
            ('with mouse', dict(input_device_class=Mouse))]
    else:
        scenarios = [
            ('with touch', dict(input_device_class=Touch))]

    def setUp(self):
        self.pointing_device = Pointer(self.input_device_class.create())
        super(AddressBookAppTestCase, self).setUp()

        if 'AUTOPILOT_APP' in os.environ:
            self.app_bin = os.environ['AUTOPILOT_APP']
        else:
            self.app_bin  = AddressBookAppTestCase.DEFAULT_DEV_LOCATION

        print "Running from: %s" % (self.app_bin)
            
        if not os.path.exists(self.app_bin):
            self.launch_test_installed()
        else:
            self.launch_test_local()

        main_view = self.main_window.get_qml_view()
        self.assertThat(main_view.visible, Eventually(Equals(True)))         

    def launch_test_local(self):            
        self.app = self.launch_test_application(self.app_bin, app_type='qt')

    def launch_test_installed(self):
        self.app = self.launch_test_application("address-book-app",
            "--desktop_file_hint=/usr/share/applications/address-book-app.desktop",
            app_type='qt')

    @property
    def main_window(self):
        return MainWindow(self.app)
