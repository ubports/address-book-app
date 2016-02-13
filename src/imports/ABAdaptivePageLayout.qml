/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 1.3

AdaptivePageLayout {
    id: layout

    function addFileToNextColumnSync(parentObject, resolvedUrl, properties) {
        return addComponentToNextColumnSync(parentObject, Qt.createComponent(resolvedUrl), properties)
    }

    function addFileToCurrentColumnSync(parentObject, resolvedUrl, properties) {
        return addComponentToCurrentColumnSync(parentObject, Qt.createComponent(resolvedUrl), properties)
    }

    function addComponentToNextColumnSync(parentObject, component, properties) {
        if (typeof(properties) === 'undefined') {
            properties = {}
        }

        var incubator = layout.addPageToNextColumn(parentObject, component, properties)
        incubator.forceCompletion()
        return incubator.object
    }

    function addComponentToCurrentColumnSync(parentObject, component, properties) {
        if (typeof(properties) === 'undefined') {
            properties = {}
        }

        var incubator = layout.addPageToCurrentColumn(parentObject, component, properties)
        incubator.forceCompletion()
        return incubator.object
    }
}
