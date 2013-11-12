# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from ubuntuuitoolkit import emulators as uitk


class MainWindow(uitk.MainView):
    """An emulator class that makes it easy to interact with the address-book-app."""

    def get_contact_list(self):
        return self.select_single("ContactListPage", "ContactList")
