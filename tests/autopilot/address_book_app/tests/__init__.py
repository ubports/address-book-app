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

    def select_a_value(self, field, value_selector, value):
        # Make sure the field has focus
        self.pointing_device.click_object(field)
        self.assertThat(field.activeFocus, Eventually(Equals(True)))

        while(value_selector.currentIndex != value):
            self.keyboard.press_and_release("Shift+Right")
            time.sleep(0.1)

    def type_on_field(self, field, text):
        edit_page = self.main_window.get_contact_edit_page()
        flickable = edit_page.wait_select_single(
            "QQuickFlickable",
            objectName="scrollArea")

        while (not field.activeFocus):
            # wait flicking stops to move to the next field
            self.assertThat(flickable.flicking, Eventually(Equals(False)))

            # use tab to move to the next field
            self.keyboard.press_and_release("Tab")
            time.sleep(0.1)

        self.assertThat(field.activeFocus, Eventually(Equals(True)))

        self.keyboard.type(text)
        self.assertThat(field.text, Eventually(Equals(text)))

    def clear_text_on_field(self, field):
        # Make sure the field has focus
        self.pointing_device.click_object(field)
        self.assertThat(field.activeFocus, Eventually(Equals(True)))

        # click on clear button
        clear_button = field.select_single("AbstractButton")
        self.pointing_device.click_object(clear_button)
        self.assertThat(field.text, Eventually(Equals("")))

    def create_new_detail(self, detailGroup):
        detCount = detailGroup.detailsCount
        add_button = detailGroup.select_single("Icon",
                                               objectName="newDetailButton")
        self.pointing_device.click_object(add_button)
        self.assertThat(detailGroup.detailsCount,
                        Eventually(Equals(detCount + 1)))

    def edit_contact(self, index):
        contacts = self.main_window.select_many("ContactDelegate")
        self.pointing_device.click_object(contacts[index])

        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(False)))

        view_page = self.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        # Edit contact
        self.main_window.open_toolbar().click_button("edit")
        self.assertThat(view_page.visible, Eventually(Equals(False)))

        edit_page = self.main_window.get_contact_edit_page()
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

        return edit_page

    def add_contact(self,
                    first_name,
                    last_name,
                    phone_numbers=None,
                    email_address=None,
                    im_address=None,
                    street_address=None,
                    locality_address=None,
                    region_address=None,
                    postcode_address=None,
                    country_address=None):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        first_name_field = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")
        last_name_field = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(first_name_field, first_name)
        self.type_on_field(last_name_field, last_name)

        if (phone_numbers):
            phoneGroup = self.main_window.select_single(
                "ContactDetailGroupWithTypeEditor",
                objectName="phones")
            for idx, number in enumerate(phone_numbers):
                if (idx > 0):
                    self.create_new_detail(phoneGroup)

                phone_number_input = self.main_window.select_single(
                    "TextInputDetail",
                    objectName="phoneNumber_" + str(idx))
                self.type_on_field(phone_number_input, number)

        if (email_address):
            emailGroup = self.main_window.select_single(
                "ContactDetailGroupWithTypeEditor",
                objectName="emails")
            for idx, address in enumerate(email_address):
                if (idx > 0):
                    self.create_new_detail(emailGroup)

                email_address_input = self.main_window.select_single(
                    "TextInputDetail",
                    objectName="emailAddress_" + str(idx))
                self.type_on_field(email_address_input, address)

        if (im_address):
            imGroup = self.main_window.select_single(
                "ContactDetailGroupWithTypeEditor",
                objectName="ims")
            for idx, address in enumerate(im_address):
                if (idx > 0):
                    self.create_new_detail(imGroup)

                im_address_input = self.main_window.select_single(
                    "TextInputDetail",
                    objectName="imUri_" + str(idx))
                self.type_on_field(im_address_input, address)

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

        edit_page = self.main_window.get_contact_edit_page()
        accept_button = edit_page.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(accept_button)

        # wait for contact list to be visible again
        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(True)))
