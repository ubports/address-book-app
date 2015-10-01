# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014, 2015 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

"""address-book-app autopilot tests and emulators - top level package."""

import logging


logging.basicConfig(filename='warning.log', level=logging.WARNING)


import autopilot.logging
import ubuntuuitoolkit
from autopilot import (
    exceptions,
    introspection
)

from address_book_app import pages
from address_book_app import address_book

logger = logging.getLogger(__name__)


class AddressBookApp(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot custom proxy object for the address book app."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        return (name == b'AddressBookApp' and
                state['applicationName'][1] == 'AddressBookApp')

    @property
    def main_window(self):
        return self.select_single(objectName='addressBookAppMainWindow')


class AddressBookAppMainWindow(ubuntuuitoolkit.MainView):

    """An emulator class that makes it easy to interact with the app."""

    @classmethod
    def validate_dbus_object(cls, path, state):
        name = introspection.get_classname_from_path(path)
        return (name == b'MainWindow' and
                state['objectName'][1] == 'addressBookAppMainWindow')

    def get_contact_list_page(self):
        # ContactListPage is the only page that can appears multiple times
        # Ex.: During the pick mode we alway push a new contactListPage, to
        # preserve the current application status.
        contact_list_pages = self.select_many(
            pages.ABContactListPage, objectName='contactListPage')

        # alway return the page without pickMode
        for p in contact_list_pages:
            if not p.pickMode:
                return p
        return None

    def get_contact_edit_page(self):
        # We can have two contact editor page because of bottom edge page
        # but we will return only the active one
        list_page = self.get_contact_list_page()
        return self.wait_select_single(objectName="contactEditorPage", active=True)

    def get_contact_view_page(self):
        return self.wait_select_single(pages.ABContactViewPage,
                                       objectName="contactViewPage",
                                       active=True)

    def get_contact_list_pick_page(self):
        contact_list_pages = self.select_many(
            pages.ABContactListPage, objectName='contactListPage')
        for p in contact_list_pages:
            if p.pickMode:
                return p
        return None

    def get_share_page(self):
        return self.wait_select_single("ContactSharePage",
                                       objectName="contactSharePage")

    def start_import_contacts(self):
        self.open_header()
        view = self.get_contact_list_view()
        if view.count > 0:
            self.click_action_button("importFromSimHeaderButton")
        else:
            import_buttom = self.select_single(
                'ContactListButtonDelegate',
                objectName='contactListView.importFromSimCardButton')
            self.pointing_device.click_object(import_buttom)

        return self.wait_select_single(address_book.SIMCardImportPage,
                                       objectName="simCardImportPage")

    def get_contact_list_view(self):
        """
        Returns a ContactListView object for the current window
        """
        return self.wait_select_single("ContactListView",
                                       objectName="contactListView")

    def get_button(self, buttonName):
        actionbars = self.select_many('ActionBar', objectName='headerActionBar')
        for actionbar in actionbars:
            try:
                button = actionbar._get_action_button(buttonName)
                return button
            except ubuntuuitoolkit.ToolkitException:
                continue
        return None

    def click_action_button(self, action_name):
        save_button = self.get_button(action_name)
        self.pointing_device.click_object(save_button)

    def open_header(self):
        header = self.get_header()
        if (header.y != 0):
            edit_page = self.get_contact_edit_page()
            flickable = edit_page.wait_select_single(
                "QQuickFlickable",
                objectName="scrollArea")

            while (header.y != 0):
                globalRect = flickable.globalRect
                start_x = globalRect.x + (globalRect.width * 0.5)
                start_y = globalRect.y + (flickable.height * 0.1)
                stop_y = start_y + (flickable.height * 0.1)

                self.pointing_device.drag(
                    start_x, start_y, start_x, stop_y, rate=5)
                # wait flicking stops to move to the next field
                flickable.flicking.wait_for(False)

        return header

    def cancel(self):
        """
        Press the 'Cancel' button
        """
        buttons = self.select_many(objectName='customBackButton')
        for button in buttons:
            if button.enabled and button.visible:
                self.pointing_device.click_object(button)
                return

        #self.click_action_button("customBackButton")

    def save(self):
        """
        Press the 'Save' button
        """
        self.click_action_button("save")

    def edit(self):
        """
        Press the 'Save' button
        """
        self.click_action_button("edit")

    def delete(self):
        """
        Press the 'Delete' button
        """
        self.click_action_button("delete")

    def confirm_import(self):
        """
        Press the 'confirm' button
        """
        self.click_action_button("confirmImport")

    def get_toolbar(self):
        """Override base class so we get our expected Toolbar subclass."""
        return self.select_single(ubuntuuitoolkit.Toolbar)

    @autopilot.logging.log_action(logger.info)
    def go_to_add_contact(self):
        """
        Press the 'Add' button and return the contact editor page
        """
        bottom_swipe_page = self.get_contact_list_page()
        bottom_swipe_page.reveal_bottom_edge_page()
        return self.get_contact_edit_page()
