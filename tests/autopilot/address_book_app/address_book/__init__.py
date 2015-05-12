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
    'ContactEditorPage',
    'ContactViewPage',
    'SIMCardImportPage',
    'RemoveContactDialog',
    'PageWithHeader',
    'PageWithBottomEdge'
]

from address_book_app.address_book._contact_editor_page \
    import ContactEditorPage
from address_book_app.address_book._contact_view_page import ContactViewPage
from address_book_app.address_book._sim_card_import_page \
    import SIMCardImportPage
from address_book_app.address_book._common import PageWithHeader
from address_book_app.address_book._common import PageWithBottomEdge
