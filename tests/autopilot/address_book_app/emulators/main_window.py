# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

from ubuntuuitoolkit import emulators as uitk


class MainWindow(uitk.MainView):
    """An emulator class that makes it easy to interact with the app."""

    def get_contact_list_page(self):
        return self. wait_select_single("ContactListPage",
                                        objectName="contactListPage")

    def get_contact_edit_page(self):
        return self.wait_select_single("ContactEditor",
                                       objectName="contactEditorPage")

    def get_contact_view_page(self):
        return self.wait_select_single("ContactView",
                                       objectName="contactViewPage")

    def get_contact_list_pick_page(self):
        pages = self.select_many("ContactListPage",
                                 objectName="contactListPage")
        for p in pages:
            if p.pickMode:
                return p
        return None

