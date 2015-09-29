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


class TestCreateNewContactFromURI(AddressBookAppTestCase):
    """Tests call the app with different uri"""

    def setUp(self):
        self.ARGS.append("addressbook:///create?phone=1234567890")
        super(TestCreateNewContactFromURI, self).setUp()

    def test_save_new_contact(self):
        list_page = self.app.main_window.get_contact_list_page()
        list_page.bottomEdgePageLoaded.wait_for(True)

        edit_page = self.app.main_window.get_contact_edit_page()
        self.assertThat(edit_page.visible, Eventually(Equals(True)))

        # add name to the contact
        firstNameField = self.app.main_window.wait_select_single(
            "TextInputDetail",
            objectName="firstName")
        lastNameField = self.app.main_window.wait_select_single(
            "TextInputDetail",
            objectName="lastName")

        self.type_on_field(firstNameField, "Fulano")
        self.type_on_field(lastNameField, "de Tal")

        # save the contact
        self.app.main_window.save()

        # open contact view
        list_page.open_contact(0)
        view_page = self.app.main_window.get_contact_view_page()
        self.assertThat(view_page.visible, Eventually(Equals(True)))

        # check if we have the new phone"""
        phone_group = view_page.select_single(
            "ContactDetailGroupWithTypeView",
            objectName="phones")
        self.assertThat(phone_group.detailsCount, Eventually(Equals(1)))
        phone_type = view_page.select_single(
            "Label",
            objectName="type_phoneNumber_0")
        phone_label = view_page.select_single(
            "Label",
            objectName="label_phoneNumber_0.0")
        self.assertThat(phone_label.text, Eventually(Equals("1234567890")))
        self.assertThat(phone_type.text, Eventually(Equals("Mobile")))
