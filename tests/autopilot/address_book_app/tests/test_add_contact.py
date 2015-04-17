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

import address_book_app
from address_book_app import data
from address_book_app.tests import AddressBookAppTestCase


class TestAddContact(AddressBookAppTestCase):
    """ Tests the Add contact """

    def test_go_to_add_contact(self):
        """Test to launch the add contact screen using emulator method"""
        self.assertRaises(
            dbus.StateNotFoundError,
            self.app.main_window.get_contact_edit_page)
        contact_editor = self.app.main_window.go_to_add_contact()
        self.assertTrue(contact_editor.visible)
        self.assertIsInstance(
            contact_editor, address_book_app.pages.ContactEditor)

    def test_add_and_cancel_contact(self):
        list_page = self.app.main_window.get_contact_list_page()

        # execute add new contact
        contact_editor = self.app.main_window.go_to_add_contact()

        # Check if the contact list disapear and contact editor appears
        self.assertThat(list_page.visible, Eventually(Equals(False)))
        self.assertThat(contact_editor.visible, Eventually(Equals(True)))

        # cancel new contact without save
        self.app.main_window.cancel()

        # Check if the contact list is visible again
        self.assertThat(list_page.visible, Eventually(Equals(True)))

        # Check if the contact list still empty
        list_view = self.app.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(0)))

    def test_add_contact_with_name_and_phone(self):
        test_contact = data.Contact(
            first_name='Fulano', last_name='de Tal',
            phones=[data.Phone.make()])

        # execute add new contact
        contact_editor = self.app.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.app.main_window.save()

        # Check if contact was added
        list_view = self.app.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_add_full_contact(self):
        test_contact = data.Contact.make_unique()
        # TODO implement the filling of professional details.
        # --elopio - 2014-03-01
        test_contact.professional_details = []

        # execute add new contact
        contact_editor = self.app.main_window.go_to_add_contact()
        contact_editor.fill_form(test_contact)

        # Save contact
        self.app.main_window.save()

        # Check if contact was added
        list_view = self.app.main_window.get_contact_list_view()
        self.assertThat(list_view.count, Eventually(Equals(1)))

    def test_email_label_save(self):
        contact_editor = self.app.main_window.go_to_add_contact()

        my_emails = []
        my_emails.append(data.Email(type_="Home", address="home@email.com"))
        my_emails.append(data.Email(type_="Work", address="work@email.com"))
        my_emails.append(data.Email(type_="Other", address="other@email.com"))

        test_contact = data.Contact(first_name="Sherlock",
                                    last_name="Holmes",
                                    emails=my_emails)
        contact_editor.fill_form(test_contact)

        # Save contact
        self.app.main_window.save()

        list_page = self.app.main_window.get_contact_list_page()
        view_page = list_page.open_contact(0)
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        # check if we have 3 emails"""
        email_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="emails")
        self.assertThat(email_group.detailsCount, Eventually(Equals(3)))

        emails = {"home@email.com": "Home",
                  "work@email.com": "Work",
                  "other@email.com": "Other"}

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
        contact_editor = self.app.main_window.go_to_add_contact()

        my_phones = []
        my_phones.append(data.Phone(type_="Home", number="(000) 000-0000"))
        my_phones.append(data.Phone(type_="Work", number="(000) 000-0001"))
        my_phones.append(data.Phone(type_="Mobile", number="(000) 000-0002"))
        my_phones.append(data.Phone(type_="Work Mobile",
                                    number="(000) 000-0003"))
        my_phones.append(data.Phone(type_="Other", number="(000) 000-0004"))

        test_contact = data.Contact(first_name="Sherlock",
                                    last_name="Holmes",
                                    phones=my_phones)
        contact_editor.fill_form(test_contact)

        # Save contact
        self.app.main_window.save()

        # Open contact view
        list_page = self.app.main_window.get_contact_list_page()
        view_page = list_page.open_contact(0)
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        # check if we have five phones"""
        phone_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="phones")
        self.assertThat(phone_group.detailsCount, Eventually(Equals(5)))

        phones = {"(000) 000-0000": "Home",
                  "(000) 000-0001": "Work",
                  "(000) 000-0002": "Mobile",
                  "(000) 000-0003": "Work Mobile",
                  "(000) 000-0004": "Other"}

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
