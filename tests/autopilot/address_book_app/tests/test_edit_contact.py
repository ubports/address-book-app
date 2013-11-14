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


class TestEditContact(AddressBookAppTestCase):
    """Tests the edit contact"""

    def test_add_new_phone(self):
        self.add_contact("Fulano", "de Tal", "3321 2300")

        """ View contact """
        contacts = self.main_window.select_many("ContactDelegate")
        self.pointing_device.click_object(contacts[0])

        list_page = self.main_window.get_contact_list_page()
        self.assertThat(list_page.visible, Eventually(Equals(False)))

        view_page = self.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        """ Edit contact """
        self.main_window.open_toolbar().click_button("edit")
        self.assertThat(view_page.visible, Eventually(Equals(False)))

        edit_page = self.main_window.get_contact_edit_page()
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

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
