# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright (C) 2014 Canonical Ltd.
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

import logging

import autopilot.logging

from address_book_app.pages import _common

logger = logging.getLogger(__name__)
log_action_info = autopilot.logging.log_action(logging.info)
log_action_debug = autopilot.logging.log_action(logging.debug)

class SIMCardImportPage(_common.PageWithHeader):
    """Autopilot helper for the ContactView page."""

    def _get_sorted_contact_delegates(self):
        # FIXME this returns only the contact delegates that are loaded in
        # memory. The list might be big, so not all delegates might be in
        # memory at the same time.
        contact_delegates = self.select_many('ContactDelegate', visible=True)
        return sorted(
            contact_delegates, key=lambda delegate: delegate.globalRect.y)

    def _get_contact_delegate(self, index):
        contact_delegates = self._get_sorted_contact_delegates()
        return contact_delegates[index]

    def _start_selection(self, index):
        # TODO change this for click_object once the press duration
        # parameter is added. See http://pad.lv/1268782
        contact = self._get_contact_delegate(index)
        self.pointing_device.move_to_object(contact)
        self.pointing_device.press()
        time.sleep(2.0)
        self.pointing_device.release()
        view = self._get_list_view()
        view.isInSelectionMode.wait_for(True)

    def _get_list_view(self):
        return self.wait_select_single(
            'ContactListView', objectName='contactListViewFromSimCard')

    @log_action_info
    def get_contacts(self):
        """Return a list with the names of the contacts."""
        contact_delegates = self._get_sorted_contact_delegates()
        name_labels = [
            delegate.select_single('Label', objectName='nameLabel') for
            delegate in contact_delegates
        ]
        return [label.text for label in name_labels]

    @log_action_info
    def select_contacts(self, indices):
        """ Select contacts corresponding to the list of index in indices

        :param indices: List of integers

        """
        contacts = []
        self._deselect_all()
        if len(indices) > 0:
            view = self._get_list_view()
            if not view.isInSelectionMode:
                self._start_selection(indices[0])
                indices = indices[1:]

            for index in indices:
                contact = self._get_contact_delegate(index)
                self.pointing_device.click_object(contact)
                contacts.append(contact.select_single('Label', objectName='nameLabel').text)

        return contacts
