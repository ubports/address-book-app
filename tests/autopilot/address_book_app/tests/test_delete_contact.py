# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

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

"""Delete tests for the Addressbook App."""

from address_book_app import tests


class TestDeleteSelectContact(tests.AddressBookAppTestCase):

    """
    Delete a contact using pick mode and verify the behavior of Cancel and
    Delete actions
    """

    PRELOAD_VCARD = True

    ALL_CONTACTS = [
        'teste test34',
        'teste teste2',
        'teste3 teste3',
    ]

    scenarios = [
        ('single_cancel', {
            'select': [ALL_CONTACTS[1]],
            'action': 'cancel',
            'expected_result': ALL_CONTACTS}),
        ('multiple_cancel', {
            'select': [ALL_CONTACTS[1], ALL_CONTACTS[2]],
            'action': 'cancel',
            'expected_result': ALL_CONTACTS}),
        ('single_delete', {
            'select': [ALL_CONTACTS[1]],
            'action': 'delete',
            'expected_result': [ALL_CONTACTS[0], ALL_CONTACTS[2]]}),
        ('multiple_delete', {
            'select': [ALL_CONTACTS[1], ALL_CONTACTS[2]],
            'action': 'delete',
            'expected_result': [ALL_CONTACTS[0]]}),
    ]

    def test_select(self):
        """
        Delete a contact in pick mode

        This test switch the contact list view to pick mode and validate the
        behavior of Cancel and delete actions by comparing the numbers of
        contact in the list before and after the action.
        Note that it doesn't check which contact has been deleted.
        """
        list_page = self.app.main_window.get_contact_list_page()

        indices = [self.ALL_CONTACTS.index(name) for name in self.select]
        list_page.select_contacts(indices)
        if self.action == "cancel":
            self.app.main_window.cancel()
        elif self.action == "delete":
            list_page.delete_selected_contacts(self.app.main_window)

        self.assertEqual(list_page.get_contacts(), self.expected_result)
