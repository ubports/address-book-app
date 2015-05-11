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

from address_book_app.address_book import data
from address_book_app import tests

class ContactEditorTestCase(tests.AddressBookAppTestCase):

    def test_fill_form(self):
        """Test that the form can be filled with contact information."""
        test_contact = data.Contact.make_unique(unique_id='test_uuid')
        # TODO implement the filling of professional details.
        # --elopio - 2014-03-01
        test_contact.professional_details = []

        contact_editor = self.app.main_window.go_to_add_contact()

        contact_editor.fill_form(test_contact)

        form_values = contact_editor._get_form_values()
        self.assertEqual(test_contact, form_values)
