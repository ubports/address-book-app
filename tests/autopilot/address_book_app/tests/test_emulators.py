# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2014 Canonical
#
# This file is part of ubuntu-integration-tests.
#
# ubuntu-integration-tests is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

from autopilot.introspection import dbus

from address_book_app import tests
from address_book_app.emulators import main_window


class MainWindowTestCase(tests.AddressBookAppTestCase):
    
    def test_go_to_add_contact(self):
        self.assertRaises(
            dbus.StateNotFoundError, self.main_window.get_contact_edit_page)
        contact_editor = self.main_window.go_to_add_contact()
        self.assertIsInstance(contact_editor, main_window.ContactEditor)


class ContactEditorTestCase(tests.AddressBookAppTestCase):

    def test_fill_form(self):
        test_form_values = dict(
            first_name='Test first name', last_name='Test last name')
        
        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_form_values)
        
        form_values = contact_editor._get_form_values()
        self.assertEqual(test_form_values, form_values)

    def test_fill_form_with_unknown_field_must_raise_error(self):
        test_form_values = dict(unknown='dummy')

        contact_editor = self.main_window.go_to_add_contact()
        error = self.assertRaises(
            main_window.AddressBookAppEmulatorException,
            contact_editor.fill_form, test_form_values)
        self.assertEqual('Unknown field: unknown.', str(error))
