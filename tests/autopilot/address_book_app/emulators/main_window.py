# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


class MainWindow(object):
    """An emulator class that makes it easy to interact with the camera-app."""

    def __init__(self, app):
        self.app = app

    def get_qml_view(self):
        """Get the main QML view"""
        return self.app.select_single("QQuickView")

    # Help function to debug objects
    def dump_parent_tree(self, parent):
        print "Parent:", parent
        if "objectName" in parent.get_properties():
            print "ObjName:", parent.get_properties()["objectName"]
        for c in parent.get_children():
            self.dump_parent_tree(c)

    def get_object(self, typeName, name=None):        
        if name:
            return self.app.select_single(typeName, objectName=name)
        else:
            return self.app.select_single(typeName)
