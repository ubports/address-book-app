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

__all__ = [
    'ContactEditor',
    'ContactListPage',
    'ContactView',
    'SIMCardImportPage',
]

from address_book_app.pages._contact_editor import ContactEditor
from address_book_app.pages._contact_list_page import ContactListPage
from address_book_app.pages._contact_view import ContactView
from address_book_app.pages._sim_card_import_page import SIMCardImportPage
