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
    """ Tests the Add contact """

    def test_add_and_cancel_contact(self):
        list_page = self.main_window.get_contact_list_page()

        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")
        edit_page = self.main_window.get_contact_edit_page()

        # Check if the contact list disapear and contact editor appears
        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

        # cancel new contact without save
        self.main_window.cancel()

        # Check if the contact list is visible again
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        # Check if the contact list still empty
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_without_name(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")
        edit_page = self.main_window.get_contact_edit_page()

        # Try to save a empty contact
        acceptButton = self.main_window.get_button("accept")

        # Save button must be disabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")

        # fill fistName field
        self.type_on_field(firstNameField, "Fulano")

        # Save button must be enabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(True)))

        # clear firstName field
        self.clear_text_on_field(firstNameField)

        # Save button must be disabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        # fill lastName field
        self.type_on_field(lastNameField, "de Tal")

        # Save button must be enabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(True)))

        # clear lastName field
        self.clear_text_on_field(lastNameField)

        # Save button must be disabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        # Clicking on disabled button should do nothing
        self.pointing_device.click_object(acceptButton)

        # Check if the contact editor still visbile
        list_page = self.main_window.get_contact_list_page()

        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

        # Check if the contact list still empty
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_with_full_name(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")

        # fill fistName field
        self.type_on_field(firstNameField, "Fulano")

        # fill lastName field
        self.type_on_field(lastNameField, "de Tal")

        # Save contact
        self.main_window.save()

        # Check if the contact list is visible again
        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_first_name(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")

        # fill fistName field
        self.type_on_field(firstNameField, "Fulano")

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_last_name(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")

        # fill fistName field
        self.type_on_field(lastNameField, "de Tal")

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_name_and_phone(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        # fill name
        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(firstNameField, "Fulano")
        self.type_on_field(lastNameField, "de Tal")

        # fill phone number
        phone_number_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="phoneNumber_0")
        self.type_on_field(phone_number_0, "55 81 8777 7755")

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_full_contact(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        # fill name
        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(firstNameField, "Sherlock")
        self.type_on_field(lastNameField, "Holmes")

        # fill phone number
        phone_number_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="phoneNumber_0")
        self.type_on_field(phone_number_0, "81 8777 7755")

        # fill email
        email_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="emailAddress_0")
        self.type_on_field(email_0, "holmes.sherlock.uk")

        # fill im
        im_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="imUri_0")
        self.type_on_field(im_0, "sh.im.com.br")

        # fill address
        street_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="streetAddress_0")
        self.type_on_field(street_0, "221B Baker Street")
        locality_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="localityAddress_0")
        self.type_on_field(locality_0, "West End")
        region_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="regionAddress_0")
        self.type_on_field(region_0, "London")
        postcode_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="postcodeAddress_0")
        self.type_on_field(postcode_0, "7777")
        country_0 = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="countryAddress_0")
        self.type_on_field(country_0, "united kingdom")

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_email_label_save(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        # fill name
        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(firstNameField, "Sherlock")
        self.type_on_field(lastNameField, "Holmes")

        # Home
        self.set_email_address(0, "home@email.com", 0) 
        # Work
        self.set_email_address(1, "work@email.com", 1)
        # Other
        self.set_email_address(2, "other@email.com", 2)

        # Save contact
        self.main_window.save()

        contacts = self.main_window.select_many("ContactDelegate")
        self.pointing_device.click_object(contacts[0])

        # check if contacts was saved with the correct labels
        view_page = self.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        # check if we have 3 emails"""
        email_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="emails")
        self.assertThat(email_group.detailsCount, Eventually(Equals(3)))

        emails = {"home@email.com" : "Home",
                  "work@email.com" : "Work",
                  "other@email.com" : "Other"}

        # Check if they have the correct label
        for idx in range(3):
            email_type = view_page.select_single(
                "Label",
                objectName="type_email_" + str(idx))

            email_label = view_page.select_single(
                "Label",
                objectName="label_emailAddress_" + str(idx) + ".0")

            self.assertThat(emails[email_label.text], Equals(email_type.text))
            del emails[email_label.text]

        self.assertThat(len(emails), Equals(0))

    def test_phone_label_save(self):
        # execute add new contact
        self.main_window.open_toolbar().click_button("Add")

        # fill name
        firstNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")
        self.type_on_field(firstNameField, "Sherlock")
        self.type_on_field(lastNameField, "Holmes")

        # Home
        self.set_phone_number(0, "00 0000 0000", 0) 
        # Work
        self.set_phone_number(1, "11 1111 1111", 1)
        # Mobile
        self.set_phone_number(2, "22 2222 2222", 2)
        # Work Mobile
        self.set_phone_number(3, "33 3333 3333", 3)
        # Other
        self.set_phone_number(4, "44 4444 4444", 4)

        # Save contact
        self.main_window.save()

        contacts = self.main_window.select_many("ContactDelegate")
        self.pointing_device.click_object(contacts[0])

        # check if contacts was saved with the correct labels
        view_page = self.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        # check if we have five phones"""
        phone_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="phones")
        self.assertThat(phone_group.detailsCount, Eventually(Equals(5)))

        phones = {"00 0000 0000" : "Home",
                  "11 1111 1111" : "Work",
                  "22 2222 2222" : "Mobile", 
                  "33 3333 3333" : "Work Mobile",
                  "44 4444 4444" : "Other"}

        # Check if they have the correct label
        for idx in range(5):
            phone_type = view_page.select_single(
                "Label",
                objectName="type_phoneNumber_" + str(idx))

            phone_label = view_page.select_single(
                "Label",
                objectName="label_phoneNumber_" + str(idx) + ".0")

            self.assertThat(phones[phone_label.text], Equals(phone_type.text))
            del phones[phone_label.text]

        self.assertThat(len(phones), Equals(0))
