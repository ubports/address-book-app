# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""address-book-app autopilot tests."""

import os.path
import os
import time
import subprocess

from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
from autopilot.platform import model
from testtools.matchers import Equals

from address_book_app.emulators.main_window import MainWindow
from ubuntuuitoolkit import emulators as toolkit_emulators


class AddressBookAppTestCase(AutopilotTestCase):
    """A common test case class that provides several useful methods for
    address-book-app tests.
    """
    DEFAULT_DEV_LOCATION = "../../src/app/address-book-app"

    def setUp(self):
        self.pointing_device = toolkit_emulators.get_pointing_device()
        super(AddressBookAppTestCase, self).setUp()

        # stop vkb
        if model() != "Desktop":
             subprocess.check_call(["/sbin/initctl", "stop", "maliit-server"])

        if 'AUTOPILOT_APP' in os.environ:
            self.app_bin = os.environ['AUTOPILOT_APP']
        else:
            self.app_bin = AddressBookAppTestCase.DEFAULT_DEV_LOCATION

        print "Running from: %s" % (self.app_bin)
        os.environ['QTCONTACTS_MANAGER_OVERRIDE'] = 'memory'

        if not os.path.exists(self.app_bin):
            self.launch_test_installed()
        else:
            self.launch_test_local()

        self.main_window.visible.wait_for(True)

    def tearDown(self):
        super(AddressBookAppTestCase, self).tearDown()

        # start the vkb
        if model() != "Desktop":
             subprocess.check_call(["/sbin/initctl", "start", "maliit-server"])

    def launch_test_local(self):
        self.app = self.launch_test_application(
            self.app_bin,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    def launch_test_installed(self):
        df = "/usr/share/applications/address-book-app.desktop"
        self.app = self.launch_test_application(
            "address-book-app",
            "--desktop_file_hint=" + df,
            app_type='qt',
            emulator_base=toolkit_emulators.UbuntuUIToolkitEmulatorBase)

    @property
    def main_window(self):
        return self.app.select_single(MainWindow)

    def type_on_field(self, field, text):
        flickable = self.main_window.get_contact_edit_page().wait_select_single(
            "QQuickFlickable",
            objectName="scrollArea")
        self.assertThat(flickable.flicking, Eventually(Equals(False)))

        while (field.activeFocus != True):
            # wait flicking stops to move to the next field
            self.assertThat(flickable.flicking, Eventually(Equals(False)))

            # use tab to move to the next field
            self.keyboard.press_and_release("Tab")
            time.sleep(0.1)

        self.assertThat(field.activeFocus, Eventually(Equals(True)))
        self.keyboard.type(text)
        self.assertThat(field.text, Eventually(Equals(text)))

    def clear_text_on_field(self, field):
        clear_button = field.select_single("AbstractButton")
        self.pointing_device.click_object(clear_button)
        self.assertThat(field.text, Eventually(Equals("")))
