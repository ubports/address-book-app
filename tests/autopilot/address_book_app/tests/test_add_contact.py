# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from testtools.matchers import Equals
from autopilot.matchers import Eventually
from autopilot.introspection import dbus

from address_book_app import data
from address_book_app.tests import AddressBookAppTestCase
from address_book_app.emulators import main_window


class TestAddContact(AddressBookAppTestCase):
    """ Tests the Add contact """

    def test_go_to_add_contact(self):
        """Test to launch the add contact screen using emulator method"""
        self.assertRaises(
            dbus.StateNotFoundError, self.main_window.get_contact_edit_page)
        contact_editor = self.main_window.go_to_add_contact()
        self.assertTrue(contact_editor.visible)
        self.assertIsInstance(contact_editor, main_window.ContactEditor)

    def test_add_and_cancel_contact(self):
        list_page = self.main_window.get_contact_list_page()

        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()

        # Check if the contact list disapear and contact editor appears
        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(contact_editor.visible, Eventually(Equals(True)))

        # cancel new contact without save
        self.main_window.cancel()

        # Check if the contact list is visible again
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        # Check if the contact list still empty
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_without_name(self):
        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()

        # Try to save a empty contact
        acceptButton = self.main_window.get_button("save")

        # Save button must be disabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        contact_editor.fill_form(data.Contact(first_name='Fulano'))

        # Save button must be enabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(True)))

        contact_editor.fill_form(data.Contact(first_name=''))

        # Save button must be disabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        contact_editor.fill_form(data.Contact(last_name='de Tal'))

        # Save button must be enabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(True)))

        # clear lastName field
        contact_editor.fill_form(data.Contact(last_name=''))

        # Save button must be disabled
        self.assertThat(acceptButton.enabled, Eventually(Equals(False)))

        # Clicking on disabled button should do nothing
        self.pointing_device.click_object(acceptButton)

        # Check if the contact editor still visbile
        list_page = self.main_window.get_contact_list_page()

        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(contact_editor.visible, Eventually(Equals(True)))

        # Check if the contact list still empty
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_with_full_name(self):
        test_contact = data.Contact(first_name='Fulano', last_name='de Tal')

        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.main_window.save()

        # Check if the contact list is visible again
        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_first_name(self):
        test_contact = data.Contact(first_name='Fulano')

        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_last_name(self):
        test_contact = data.Contact(last_name='de Tal')

        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_contact_with_name_and_phone(self):
        test_contact = data.Contact(
            first_name='Fulano', last_name='de Tal',
            phones=[data.Phone.make()])

        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_full_contact(self):
        test_contact = data.Contact.make_unique()
        # TODO implement the filling of professional details.
        # --elopio - 2014-03-01
        test_contact.professional_details = []

        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.main_window.save()

        # Check if contact was added
        list_view = self.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_email_label_save(self):
        # execute add new contact
        contact_editor = self.main_window.go_to_add_contact()

        # fill name
        contact_editor.fill_form(
            data.Contact(first_name='Sherlock', last_name='Holmes'))

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
        contact_editor = self.main_window.go_to_add_contact()

        # fill name
        contact_editor.fill_form(
            data.Contact(first_name='Sherlock', last_name='Holmes'))

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
