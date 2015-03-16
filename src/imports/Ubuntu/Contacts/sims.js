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

var sims = [];

function add (sim) {
    sims.push(sim);
}

function getAll () {
    return sims;
}

function get (n) {
    return getAll()[n];
}

function getCount () {
    return getAll().length;
}

function getPresent () {
    var present = [];
    getAll().forEach(function (sim) {
        if (sim.present) {
            present.push(sim);
        } else {
            return;
        }
    });
    return present;
}

function getPresentCount () {
    return getPresent().length;
}

function createQML (modems) {
    var component = Qt.createComponent("Ofono.qml");

    sims.forEach(function (sim) {
        sim.destroy();
    });
    sims = [];

    modems.forEach(function (path, index) {
        var sim = component.createObject(root, {
            path: path,
            name: phoneSettings.simNames[path] ?
                phoneSettings.simNames[path] :
                "SIM " + (index + 1)
        });
        if (sim === null) {
            console.warn('Failed to create Sim qml:',
                component.errorString());
        } else {
            Sims.add(sim);
        }
    });
}

