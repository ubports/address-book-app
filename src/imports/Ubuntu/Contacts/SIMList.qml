/*
 * Copyright (C) 2015 Canonical, Ltd.
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

import QtQuick 2.4

import MeeGo.QOfono 0.2

import GSettings 1.0

Item {
    id: root

    property var sims: []
    property var present: []

    function filterPresentSims()
    {
        var presentSims = []
        sims.forEach(function (sim) {
            if (sim.present) {
                presentSims.push(sim)
            }
        });
        root.present = presentSims
    }

    function createQML (modems)
    {
        if (!phoneSettings.simNames) {
            return
        }

        var component = Qt.createComponent(Qt.resolvedUrl("Ofono.qml"));

        sims.forEach(function (sim) {
            sim.destroy();
        });
        var newSims = []
        var presentSims = []

        modems.forEach(function (path, index) {
            var sim = component.createObject(root, {
                path: path,
                name: phoneSettings.simNames[path] ? phoneSettings.simNames[path] :
                                                     "SIM " + (index + 1)
            });
            if (sim === null) {
                console.warn('Failed to create Sim qml:', component.errorString());
            } else {
                newSims.push(sim)
                if (sim.present) {
                    presentSims.push(sim)
                }
                sim.onPresentChanged.connect(filterPresentSims)
            }
        });

        root.sims = newSims
        root.present = presentSims
    }


    GSettings {
        id: phoneSettings
        schema.id: "com.ubuntu.phone"
        onChanged: {
            if (key === "simNames") {
                root.createQML(ofonoManager.modems.slice(0).sort())
            }
        }
        onSchemaChanged: root.createQML(ofonoManager.modems.slice(0).sort())
    }

    OfonoManager {
        id: ofonoManager
        onModemsChanged: root.createQML(modems.slice(0).sort())
    }
}
