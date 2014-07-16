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
        # all selection marks should be invisible
        selection_marks = []
        mark_to_contacts = {}
        for contact in contacts:
            if (contact.visible):
                mark = contact.select_single("QQuickRectangle", objectName="selectionMark")
                self.assertThat(mark.opacity, Eventually(Equals(0.0)))
                selection_marks.append(mark)
                mark_to_contacts[mark] = contact

        # click on mark 1
        selected_mark = selection_marks[1]
        self.pointing_device.click_object(selected_mark)

        for mark in selection_marks:
            if mark == selected_mark:
                self.assertThat(mark_to_contacts[mark].selected, Eventually(Equals(True)))
            else:
                self.assertThat(mark_to_contacts[mark].selected, Eventually(Equals(False)))

        # click on mark 2
        selected_mark = selection_marks[2]
        self.pointing_device.click_object(selected_mark)

        for mark in selection_marks:
            if mark == selected_mark:
                self.assertThat(mark_to_contacts[mark].selected, Eventually(Equals(True)))
            else:
                self.assertThat(mark_to_contacts[mark].selected, Eventually(Equals(False)))

        # click on mark 0
        selected_mark = selection_marks[0]
        self.pointing_device.click_object(selected_mark)

        for mark in selection_marks:
            if mark == selected_mark:
                self.assertThat(mark_to_contacts[mark].selected, Eventually(Equals(True)))
            else:
                self.assertThat(mark_to_contacts[mark].selected, Eventually(Equals(False)))

        buttons = pick_page.select_many("Button", objectName="DialogButtons.acceptButton")
        for b in buttons:
            if b.visible:
                self.pointing_device.click_object(b)

