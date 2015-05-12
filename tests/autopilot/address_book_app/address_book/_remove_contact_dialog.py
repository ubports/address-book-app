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

import autopilot.logging
import ubuntuuitoolkit


logger = logging.getLogger(__name__)


class RemoveContactsDialog(
        ubuntuuitoolkit.UbuntuUIToolkitCustomProxyObjectBase):

    """Autopilot helper for the Remove Contacts dialog."""

    @autopilot.logging.log_action(logger.debug)
    def confirm_removal(self):
        button = self.select_single(
            'Button', objectName='removeContactsDialog.Yes')
        self.pointing_device.click_object(button)
        self.wait_until_destroyed()
