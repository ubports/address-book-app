# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

"""Tests for the Addressbook App"""

from testtools.matchers import Equals
from autopilot.matchers import Eventually

from address_book_app.tests import AddressBookAppTestCase


class TestSinglePickerMode(AddressBookAppTestCase):
    """ Tests app in single picker mode"""

    def setUp(self):
        AddressBookAppTestCase.ARGS.append("addressbook:///pick?single=true")
        AddressBookAppTestCase.PRELOAD_VCARD = True
        super(TestSinglePickerMode, self).setUp()

    def test_select_single_contact(self):
        pick_page = self.app.main_window.get_contact_list_pick_page()
        contacts = pick_page.select_many("ContactDelegate")
        # all selection items should be invisible
        selected_items = []
        item_to_contacts = {}
        for contact in contacts:
            if (contact.visible):
                item = contact.select_single("QQuickRectangle", objectName="mainItem")
                self.assertThat(item.color, Eventually(Equals(contact.color)))
                selected_items.append(item)
                item_to_contacts[item] = contact

        # click on item 1
        selected_item = selected_items[1]
        self.pointing_device.click_object(selected_item)

        for item in selected_items:
            if item == selected_item:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(True)))
                self.assertThat(item.color, Eventually(Equals(contact.selectedColor)))
            else:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(False)))
                self.assertThat(item.color, Eventually(Equals(contact.color)))

        # click on item 2
        selected_item = selected_items[2]
        self.pointing_device.click_object(selected_item)

        for item in selected_items:
            if item == selected_item:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(True)))
                self.assertThat(item.color, Eventually(Equals(contact.selectedColor)))
            else:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(False)))
                self.assertThat(item.color, Eventually(Equals(contact.color)))

        # click on item 0
        selected_item = selected_items[0]
        self.pointing_device.click_object(selected_item)

        for item in selected_items:
            if item == selected_item:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(True)))
                self.assertThat(item.color, Eventually(Equals(contact.selectedColor)))
            else:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(False)))
                self.assertThat(item.color, Eventually(Equals(contact.color)))

        buttons = pick_page.select_many("Button", objectName="DialogButtons.acceptButton")
        for b in buttons:
            if b.visible:
                self.pointing_device.click_object(b)

