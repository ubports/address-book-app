#!/usr/bin/python3

'''buteo syncfw mock template

This creates the expected methods and properties of the main
com.meego.msyncd object. You can specify D-BUS property values
'''

# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation; either version 3 of the License, or (at your option) any
# later version.  See http://www.gnu.org/copyleft/lgpl.html for the full text
# of the license.

__author__ = 'Renato Araujo Oliveira Filho'
__email__ = 'renatofilho@canonical.com'
__copyright__ = '(c) 2015 Canonical Ltd.'
__license__ = 'LGPL 3+'

import dbus
from gi.repository import GObject

import dbus
import dbus.service
import dbus.mainloop.glib

BUS_NAME = 'com.meego.msyncd'
MAIN_OBJ = '/synchronizer'
MAIN_IFACE = 'com.meego.msyncd'
SYSTEM_BUS = False

class ButeoSyncFw(dbus.service.Object):
    DBUS_NAME = None

    def __init__(self, object_path):
        dbus.service.Object.__init__(self, dbus.SessionBus(), object_path)
        self._mainloop = GObject.MainLoop()
        self._profiles = {}

    def _mock_profile_create(self, profileName):
        self.signalProfileChanged(profileName, 0, '')
        return False

    def _mock_sync_start(self, profileName):
        self.syncStatus(profileName, 1, '', 0)
        return False

    def _mock_sync_finished(self, profileName):
        self.syncStatus(profileName, 4, '', 100)
        return False

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='i', out_signature='s')
    def createSyncProfileForAccount(self, accountId):
        profileName = "profile-" + str(accountId)
        self._profiles[accountId] = profileName
        GObject.timeout_add(1000, self._mock_profile_create, profileName)
        GObject.timeout_add(2000, self._mock_sync_start, profileName)
        GObject.timeout_add(3000, self._mock_sync_finished, profileName)
        return profileName

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='ss', out_signature='as')
    def syncProfilesByKey(self, key, value):
        if key == "accountid" and (value in self._profiles):
            return [self._profiles[value]]
        else:
            return []

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='s', out_signature='b')
    def removeProfile(self, profileId):
        if profileId in self._profiles:
            return True
        else:
            return False

    @dbus.service.signal(dbus_interface=MAIN_IFACE,
                         signature='sisi')
    def syncStatus(self, profileId, status, message, statusDetails):
        print("SyncStatus called")

    @dbus.service.signal(dbus_interface=MAIN_IFACE,
                         signature='sis')
    def signalProfileChanged(self, profileId, status, changedProfile):
        print("profileChanged called")

    def _run(self):
        self._mainloop.run()

if __name__ == '__main__':
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    ButeoSyncFw.DBUS_NAME = dbus.service.BusName(BUS_NAME)
    buteo = ButeoSyncFw(MAIN_OBJ)
    buteo._run()
