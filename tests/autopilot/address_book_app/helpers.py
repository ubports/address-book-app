# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Copyright 2014 Canonical Ltd.
# Author: Omer Akram <omer.akram@canonical.com>
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

from autopilot.platform import model

import subprocess
import sys
import time
import dbus

def get_phonesim():
    bus = dbus.SystemBus()
    try:
        manager = dbus.Interface(bus.get_object('org.ofono', '/'),
                                 'org.ofono.Manager')
    except dbus.exceptions.DBusException:
        return False

    modems = manager.GetModems()

    for path, properties in modems:
        if path == '/phonesim':
            return properties

    return None


def is_phonesim_running():
    """Determine whether we are running with phonesim."""
    phonesim = get_phonesim()
    return phonesim is not None
