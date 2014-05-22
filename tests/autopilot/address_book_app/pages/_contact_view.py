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

from address_book_app.pages import _common


class ContactView(_common.PageWithHeader):
    """Autopilot helper for the ContactView page."""

    def go_to_edit_contact(self):
        from address_book_app.emulators import main_window
        main = self.get_root_instance().select_single(main_window.MainWindow)
        main.get_header().click_action_button('edit')
        return main.get_contact_edit_page()
