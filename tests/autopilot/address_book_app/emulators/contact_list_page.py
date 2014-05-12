# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

""" ContactListPage emulator for Addressbook App tests """

# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import logging

from autopilot.introspection.dbus import StateNotFoundError
from ubuntuuitoolkit import emulators as uitk

LOGGER = logging.getLogger(__name__)
from time import sleep


class ContactListPage(uitk.UbuntuUIToolkitEmulatorBase):
    """ ContactListPage emulator class """

    def __init__(self, *args):
        self.contacts = None
        self.selection_marks = []
        self.selected_marks = []
        super(ContactListPage, self).__init__(*args)

    def _get_list_view(self):
        return self.wait_select_single("ContactListView",
                                       objectName="contactListView")

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

    def start_selection(self, idx):
        view = self._get_list_view()
        if not view.isInSelectionMode:
            self.get_contacts()
            self.selected_marks.append(self.selection_marks[idx])
            self.pointing_device.move_to_object(self.contacts[idx])
            self.pointing_device.press()
            sleep(2.0)
            self.pointing_device.release()
            view.isInSelectionMode.wait_for(True)
        else:
            self.selected_marks.append(self.selection_marks[idx])
            self.pointing_device.click_object(self.selection_marks[idx])


    def select_contacts_by_index(self, indices):
        """ Select contacts corresponding to the list of index in indices

        :param indices: List of integers
        """
        self.deselect_all()
        if len(indices) > 0:
            self.start_selection(indices[0])

            # Select matching indices
            for idx in indices[1:]:
                self.selected_marks.append(self.selection_marks[idx])
                self.pointing_device.click_object(self.selection_marks[idx])

    def deselect_all(self):
        """Deselect every contacts"""
        contacts = self.select_many("ContactDelegate")
        self.selected_marks = []
        for contact in contacts:
            if contact.selected:
                mark = contact.select_single("QQuickRectangle",
                                             objectName="selectionMark")
                self.pointing_device.click_object(mark)

    def click_button(self, parent, objectname):
        """Press a button that matches objectname

        :param objectname: Name of the object
        """
        if parent:
            obj = parent
        else:
            obj = self
        try:
            buttons = obj.select_many("Button",
                                       objectName=objectname)
            for button in buttons:
                if button.visible:
                    self.pointing_device.click_object(button)
        except StateNotFoundError:
            LOGGER.error(
                'Button with objectName "{0}" not found.'.format(objectname)
            )
            raise

    def delete(self, main_window):
        main_window.done_selection()
        dialog = main_window.wait_select_single("RemoveContactsDialog",
            objectName="removeContactsDialog")
        self.click_button(main_window, "removeContactsDialog.Yes")

