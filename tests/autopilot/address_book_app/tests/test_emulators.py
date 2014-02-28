# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2014 Canonical
#
# This file is part of address-book-app
#
# address-book-app is free software: you can redistribute it and/or
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

from address_book_app import tests
from address_book_app.emulators import main_window


class ContactEditorTestCase(tests.AddressBookAppTestCase):

    def test_fill_form(self):
        test_form_values = {
            'first_name': 'Test first name',
            'last_name': 'Test last name'
        }

        contact_editor = self.main_window.go_to_add_contact()
        contact_editor.fill_form(test_form_values)

        form_values = contact_editor._get_form_values()
        self.assertEqual(test_form_values, form_values)

    def test_fill_form_with_unknown_field_must_raise_error(self):
        test_form_values = {'unknown': 'dummy'}

        contact_editor = self.main_window.go_to_add_contact()
        error = self.assertRaises(
            main_window.AddressBookAppError,
            contact_editor.fill_form, test_form_values)
        self.assertEqual('Unknown field: unknown.', str(error))
