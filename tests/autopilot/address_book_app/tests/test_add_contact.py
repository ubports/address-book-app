# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from __future__ import absolute_import

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from address_book_app.tests import AddressBookAppTestCase


class TestAddContact(AddressBookAppTestCase):
    """Tests the Add contact"""

    def test_add_and_cancel_contact(self):
        list_page = self.main_window.get_contact_list_page()

        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")
        edit_page = self.main_window.get_contact_edit_page()

        """ Check if the contact list disapear and contact editor appears """
        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

        """ cancel new contact without save """
        cancelButton = self.main_window.select_single(
            "Button",
            objectName="reject")
        self.pointing_device.click_object(cancelButton)

        """ Check if the contact list is visible again """
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        """ Check if the contact list still empty """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_without_name(self):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")
        edit_page = self.main_window.get_contact_edit_page()

        """ Try to save a empty contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")

        """ Save button must be disabled """
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        firstNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")

        """ fill fistName field """
        self.type_on_field(firstNameField, "Fulano")

        """ Save button must be enabled """
        self.assertThat(acceptButton.enabled, Eventually(Equals(True)))

        """ clear firstName field """
        self.clear_text_on_field(firstNameField)

        """ Save button must be disabled """
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        """ fill lastName field """
        self.type_on_field(lastNameField, "de Tal")

        """ Save button must be enabled """
        self.assertThat(acceptButton.enabled, Eventually(Equals(True)))

        """ clear lastName field """
        self.clear_text_on_field(lastNameField)

        """ Save button must be disabled """
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        """ Clicking on disabled button should do nothing """
        self.pointing_device.click_object(acceptButton)

        """ Check if the contact editor still visbile """
        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

        """ Check if the contact list still empty """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_with_full_name(self):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")

        firstNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")

        """ fill fistName field """
        self.type_on_field(firstNameField, "Fulano")

        """ fill lastName field """
        self.type_on_field(lastNameField, "de Tal")

        """ Save contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ Check if the contact list is visible again """
        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        """ Check if contact was added """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_first_name(self):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")

        firstNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")

        """ fill fistName field """
        self.type_on_field(firstNameField, "Fulano")

        """ Save contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ Check if contact was added """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_last_name(self):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")

        lastNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")

        """ fill fistName field """
        self.type_on_field(lastNameField, "de Tal")

        """ Save contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ Check if contact was added """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_name_and_phone(self):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")

        """ fill name """
        firstNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(firstNameField, "Fulano")
        self.type_on_field(lastNameField, "de Tal")

        """ fill phone number """
        phone_number_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="phoneNumber_0")
        self.type_on_field(phone_number_0, "+55 81 8777 7755")

        """ Save contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ Check if contact was added """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_full_contact(self):
        """ execute add new contact """
        self.main_window.open_toolbar().click_button("Add")

        """ fill name """
        firstNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(firstNameField, "Sherlock")
        self.type_on_field(lastNameField, "Holmes")

        """ fill phone number """
        phone_number_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="phoneNumber_0")
        self.type_on_field(phone_number_0, "81 8777 7755")

        """ fill email """
        email_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="emailAddress_0")
        self.type_on_field(email_0, "holmes@sherlock.uk")

        """ fill im """
        im_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="imUri_0")
        self.type_on_field(im_0, "sh@im.com.br")

        """ fill address """
        street_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="streetAddress_0")
        self.type_on_field(street_0, "221B Baker Street")
        locality_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="localityAddress_0")
        self.type_on_field(locality_0, "West End")
        region_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="regionAddress_0")
        self.type_on_field(region_0, "London")
        postcode_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="postcodeAddress_0")
        self.type_on_field(postcode_0, "7777")
        country_0 = self.main_window.select_single(
            "TextInputDetail",
            objectName="countryAddress_0")
        self.type_on_field(country_0, "united kingdom")

        """ Save contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ Check if contact was added """
        list_view = self.main_window.select_single(
            "ContactListView",
            objectName="contactListView")
        self.assertThat(list_view.count, Eventually(Equals(1)))
