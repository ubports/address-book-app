# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""address-book-app autopilot tests."""

import os.path
import os

from autopilot.testcase import AutopilotTestCase
from autopilot.matchers import Eventually
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
        x, y, w, h = field.globalRect

        """ Drag start possition """
        px = x + (w / 2)
        py = y + h + 3

        """ Make sure that the field is visible """
        flickable = self.main_window.get_contact_edit_page().select_single(
            "QQuickFlickable",
            objectName="scrollArea")
        self.pointing_device.drag(px, py, px, 0)
        self.assertThat(flickable.flicking, Eventually(Equals(False)))

        self.pointing_device.click_object(field)
        self.assertThat(field.activeFocus, Eventually(Equals(True)))
        self.keyboard.type(text)
        self.assertThat(field.text, Eventually(Equals(text)))

    def clear_text_on_field(self, field):
        clear_button = field.select_single("AbstractButton")
        self.pointing_device.click_object(clear_button)
        self.assertThat(field.text, Eventually(Equals("")))

    def create_new_detail(self, detailGroup):
        detCount = detailGroup.detailsCount
        add_button = detailGroup.select_single("Icon", objectName="newDetailButton")
        self.pointing_device.click_object(add_button)
        self.assertThat(detailGroup.detailsCount, Eventually(Equals(detCount + 1)))

    def add_contact(self,
        first_name,
        last_name,
        phone_number = None,
        email_address = None,
        im_address = None ,
        street_address = None,
        locality_address = None,
        region_address = None,
        postcode_address = None,
        country_address = None):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")

        first_name_field = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")
        last_name_field = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(first_name_field, first_name)
        self.type_on_field(last_name_field, last_name)

        if (phone_number):
            phone_number_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="phoneNumber_0")
            self.type_on_field(phone_number_0, phone_number)

        if (email_address):
            email_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="emailAddress_0")
            self.type_on_field(email_0, email_address)

        if (im_address):
            im_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="imUri_0")
            self.type_on_field(im_0, im_address)

        if (street_address):
            street_0 = self.main_window.selepostcode_addressct_single(
                "TextInputDetail",
                objectName="streetAddress_0")
            self.type_on_field(street_0, street_address)

        if (locality_address):
            locality_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="localityAddress_0")
            self.type_on_field(locality_0, locality_address)

        if (region_address):
            region_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="regionAddress_0")
            self.type_on_field(region_0, region_address)

        if (postcode_address):
            postcode_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="postcodeAddress_0")
            self.type_on_field(postcode_0, postcode_address)

        if (country_address):
            country_0 = self.main_window.select_single(
                "TextInputDetail",
                objectName="countryAddress_0")
            self.type_on_field(country_0, country_address)

        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)
