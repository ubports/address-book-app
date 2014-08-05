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

import logging

import ubuntuuitoolkit
from autopilot.introspection import dbus


logger = logging.getLogger(__name__)


class PageWithHeader(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    def get_header(self):
        """Return the Header custom proxy object of the Page."""
        return self.get_root_instance().select_single(
            'MainWindow').get_header()


class PageWithBottomEdge(ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):
    """An emulator class that makes it easy to interact with the bottom edge
       swipe page"""

    def reveal_bottom_edge_page(self):
        """Bring the bottom edge page to the screen"""
        try:
            action_item = self.wait_select_single(objectName='bottomEdgeTip')
            start_x = (action_item.globalRect.x +
                       (action_item.globalRect.width * 0.5))
            start_y = action_item.globalRect.y + (action_item.height * 0.2)
            stop_y = start_y - (self.height * 0.7)
            self.pointing_device.drag(
                start_x, start_y, start_x, stop_y, rate=2)
            self.isReady.wait_for(True)
        except dbus.StateNotFoundError:
            logger.error('ButtomEdge element not found.')
            raise
