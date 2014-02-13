# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

""" ContactListPage emulator for Addressbook App tests """

# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from ubuntuuitoolkit import emulators as uitk
from autopilot.introspection.dbus import StateNotFoundError
import logging
LOGGER = logging.getLogger(__name__)
from time import sleep


class ContactListPage(uitk.UbuntuUIToolkitEmulatorBase):
    """ ContactListPage emulator class """

    def __init__(self, *args):
        self.contacts = None
        self.selection_marks = []
        self.selected_marks = []
        super(ContactListPage, self).__init__(*args)

    def get_contacts(self):
        """
        Returns a list of ContactDelegate objects and populate
        self.selection_marks
        """
        sleep(1)
        self.contacts = self.select_many("ContactDelegate")
        self.selection_marks = []
        for contact in self.contacts:
            if contact.visible:
                mark = contact.select_single("QQuickRectangle",
                                             objectName="selectionMark")
                self.selection_marks.append(mark)
        return self.contacts

    def select_contacts_by_index(self, indices):
        """ Select contacts corresponding to the list of index in indices

        :param indices: List of integers
        """
        # Unselect all
        for mark in self.selected_marks:
            self.pointing_device.click_object(mark)
        self.selected_marks = []

        # Select matching indices
        for idx in indices:
            self.selected_marks.append(self.selection_marks[idx])
            self.pointing_device.click_object(self.selection_marks[idx])

    def click_button(self, objectname):
        """Press a button that matches objectname

        :param objectname: Name of the object
        """
        try:
            buttons = self.select_many("Button",
                                       objectName=objectname)
            for button in buttons:
                if button.visible:
                    self.pointing_device.click_object(button)
        except StateNotFoundError:
            LOGGER.error(
                'Button with objectName "{0}" not found.'.format(objectname)
            )
            raise

    def cancel(self):
        """Press the cancel button displayed when pick mode is enabled"""
        self.click_button("DialogButtons.rejectButton")

    def delete(self):
        """Press the delete button displayed when pick mode is enabled"""
        self.click_button("DialogButtons.acceptButton")
        self.get_contacts()
