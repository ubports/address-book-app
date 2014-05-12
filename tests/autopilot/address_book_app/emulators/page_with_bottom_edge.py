# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-

""" PageWithBottomEdge emulator """

# Copyright 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.

import logging
from address_book_app.emulators.contact_list_page import ContactListPage
from autopilot.introspection.dbus import StateNotFoundError
from ubuntuuitoolkit import emulators as toolkit_emulators

logger = logging.getLogger(__name__)
      
class PageWithBottomEdge(ContactListPage):
    """An emulator class that makes it easy to interact with the bottom edge
       swipe page"""
    def __init__(self, *args):
        super(PageWithBottomEdge, self).__init__(*args)

    def revel_bottom_edge_page(self):
        """Bring the bottom edge page to the screen"""
        try:
            action_item = self.wait_select_single('QQuickItem', objectName='bottomEdgeTip')
            start_x = action_item.globalRect.x + (action_item.globalRect.width * 0.5)
            start_y = action_item.globalRect.y + (action_item.height * 0.5)
            stop_y = start_y - (self.height * 0.5)
            self.pointing_device.drag(start_x, start_y, start_x, stop_y, rate=5)
            self.isReady.wait_for(True)
        except StateNotFoundError:
            logger.error('ButtomEdge element not found.')
            raise

class ContactListPage(PageWithBottomEdge):
    pass

