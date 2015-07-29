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

BUS_NAME = 'com.canonical.pim'
MAIN_OBJ = '/com/canonical/pim/AddressBook'
MAIN_IFACE = 'com.canonical.pim.AddressBook'

VIEW_OBJ = '/com/canonical/pim/AddressBookView'
VIEW_IFACE = 'com.canonical.pim.AddressBookView'
SYSTEM_BUS = False

class AddressBookView(dbus.service.Object):
    DBUS_NAME = None

    def __init__(self, object_path):
        dbus.service.Object.__init__(self, dbus.SessionBus(), object_path)
        self._mainloop = GObject.MainLoop()
        self._sources = {}

    @dbus.service.method(dbus_interface=VIEW_IFACE,
                         in_signature='asii', out_signature='as')
    def contactsDetails(self, fiels, startIndex, pageSize):
        return []

class AddressBook(dbus.service.Object):
    DBUS_NAME = None

    def __init__(self, object_path):
        dbus.service.Object.__init__(self, dbus.SessionBus(), object_path)
        self._mainloop = GObject.MainLoop()
        self._view = AddressBookView(VIEW_OBJ)
        self._sources = {}

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='', out_signature='a(ssssubb)')
    def availableSources(self):
        return self._sources.values()

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='s', out_signature='b')
    def removeSource(self, sourceId):
        if sourceId in self._sources:
            del self._sources[sourceId]
            return True
        else:
            return False

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='as', out_signature='i')
    def removeContacts(self, contactIds):
        count = 0
        for id in contactIds:
            if sourceId in self._sources:
                del self._sources[sourceId]
                count += 1
        return count

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='ssas', out_signature='o')
    def query(self, clause, sort, sources):
        return VIEW_OBJ

    @dbus.service.method(dbus.PROPERTIES_IFACE,
                         in_signature='ss', out_signature='v')
    def Get(self, interface_name, prop_name):
        if interface_name == MAIN_IFACE:
            if property_name == 'isReady':
                return True
        return None

    @dbus.service.signal(dbus_interface=MAIN_IFACE,
                         signature='')
    def readyChanged(self):
        print("readyChanged called")

    @dbus.service.signal(dbus_interface=MAIN_IFACE,
                         signature='as')
    def contactsAdded(self, contacts):
        print("contactsAdded called")

    @dbus.service.signal(dbus_interface=MAIN_IFACE,
                         signature='as')
    def contactsRemoved(self, contacts):
        print("contactsRemoved called")

    @dbus.service.signal(dbus_interface=MAIN_IFACE,
                         signature='as')
    def contactsUpdated(self, contacts):
        print("contactsUpdated called")


    #helper functions
    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='ssssibb', out_signature='b')
    def createSource(self, sourceId, sourceName, provider, applicationId, accountId, readOnly, primary):
        self._sources[sourceId] = (sourceId, sourceName, provider, applicationId, accountId, readOnly, primary)
        return True

    @dbus.service.method(dbus_interface=MAIN_IFACE,
                         in_signature='', out_signature='b')
    def reset(self):
        self._sources = {}
        return True

    def _run(self):
        self._mainloop.run()

if __name__ == '__main__':
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    AddressBook.DBUS_NAME = dbus.service.BusName(BUS_NAME)
    galera = AddressBook(MAIN_OBJ)

    galera._run()
