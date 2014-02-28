# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

""" Toolbar emulator for Addressbook App tests """

# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
from autopilot.introspection.dbus import StateNotFoundError
import logging
from ubuntuuitoolkit import emulators as toolkit_emulators

logger = logging.getLogger(__name__)


class Toolbar(toolkit_emulators.Toolbar):
    """An emulator class that makes it easy to interact with the tool bar"""
    def __init__(self, *args):
        super(Toolbar, self).__init__(*args)

    def click_action_item_by_text(self, text):
        """Click an action item in the tool labelled 'text'

        :param text: label of the ActionItem
        """
        try:
            action_item = self.select_single('ActionItem', text=text)
            self.pointing_device.click_object(action_item)
        except StateNotFoundError:
            logger.error(
                'ActionItem with text "{0}" not found.'.format(text)
            )
            raise

    def click_select(self):
        """Press 'Select' button on the toolbar"""
        self.click_action_item_by_text("Select")
