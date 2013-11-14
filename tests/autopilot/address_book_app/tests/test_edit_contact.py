# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from __future__ import absolute_import
import time
from testtools.matchers import Equals
from autopilot.matchers import Eventually

from address_book_app.tests import AddressBookAppTestCase


class TestEditContact(AddressBookAppTestCase):
    """Tests the edit contact"""

    def test_add_new_phone(self):
        self.add_contact("Fulano", "de Tal", ["3321 2300"])
        edit_page = self.edit_contact(0)

        """ Add a new phone """
        phoneGroup = edit_page.select_single(
            "ContactDetailGroupWithTypeEditor",
            objectName="phones")
        self.create_new_detail(phoneGroup)

        """ fill phone number """
        phone_number_1 = self.main_window.select_single(
            "TextInputDetail",
            objectName="phoneNumber_1")
        self.type_on_field(phone_number_1, "22 2222 2222")

        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ go back to view page """
        view_page = self.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        """ check if we have two phones """
        phone_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="phones")
        self.assertThat(phone_group.detailsCount, Eventually(Equals(2)))

        """ check if the new value is correct """
        phone_label_1 = view_page.select_single(
            "Label",
            objectName="label_phoneNumber_1.0")
        self.assertThat(phone_label_1.text, Eventually(Equals("22 2222 2222")))

    def test_remove_phone(self):
        self.add_contact("Fulano", "de Tal", ["3321 2300", "3321 2301"])
        edit_page = self.edit_contact(0)

        """ clear phone 1 """
        phone_number_1 = self.main_window.select_single(
            "TextInputDetail",
            objectName="phoneNumber_1")
        self.clear_text_on_field(phone_number_1)

        """ Save contact """
        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ check if we have onlye one phone """
        view_page = self.main_window.get_contact_view_page()
        phone_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="phones")
        self.assertThat(phone_group.detailsCount, Eventually(Equals(1)))

        """ check if the new value is correct """
        phone_label_1 = view_page.select_single(
            "Label",
            objectName="label_phoneNumber_0.0")
        self.assertThat(phone_label_1.text, Eventually(Equals("3321 2300")))

    def test_add_email(self):
        self.add_contact("Fulano", "")
        edit_page = self.edit_contact(0)

        """ fill email address """
        email_field = self.main_window.select_single(
            "TextInputDetail",
            objectName="emailAddress_0")
        self.type_on_field(email_field, "fulano@internet.com.br")

        acceptButton = self.main_window.select_single(
            "Button",
            objectName="accept")
        self.pointing_device.click_object(acceptButton)

        """ go back to view page """
        view_page = self.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        """ check if we have a new email """
        email_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="emails")
        self.assertThat(email_group.detailsCount, Eventually(Equals(1)))

        """ check if the new value is correct """
        phone_label_1 = view_page.select_single(
            "Label",
            objectName="label_emailAddress_0.0")
        self.assertThat(phone_label_1.text, Eventually(Equals("fulano@internet.com.br")))



