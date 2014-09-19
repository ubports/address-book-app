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


class TestMultiplePickerMode(AddressBookAppTestCase):
    """ Tests app in single picker mode"""

    PRELOAD_VCARD = True

    def setUp(self):
        self.ARGS.append("addressbook:///pick?single=false")
        super(TestMultiplePickerMode, self).setUp()

    def test_select_contacts(self):
        pick_page = self.app.main_window.get_contact_list_pick_page()
        contacts = pick_page.select_many("ContactDelegate")

        # all items should be invisible
        items = []
        item_to_contacts = {}
        for contact in contacts:
            if (contact.visible):
                item = contact.select_single("QQuickRectangle", objectName="mainItem")
                self.assertThat(item.color, Eventually(Equals(contact.color)))
                items.append(item)
                item_to_contacts[item] = contact

        # click on mark 1
        selected_items = [ items[1] ]
        self.pointing_device.click_object(items[1])

        for item in items:
            if item in selected_items:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(True)))
            else:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(False)))

        # click on mark 2
        selected_items.append(items[2])
        self.pointing_device.click_object(items[2])

        for item in items:
            if item in selected_items:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(True)))
            else:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(False)))

        # click on mark 0
        selected_items.append(items[0])
        self.pointing_device.click_object(items[0])

        for item in items:
            if item in selected_items:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(True)))
            else:
                self.assertThat(item_to_contacts[item].selected, Eventually(Equals(False)))

        buttons = pick_page.select_many("Button", objectName="DialogButtons.acceptButton")
        for b in buttons:
            if b.visible:
                self.pointing_device.click_object(b)

