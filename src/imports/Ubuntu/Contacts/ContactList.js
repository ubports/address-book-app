/*
 * Copyright 2012-2015 Canonical Ltd.
 *
 * This file is part of address-book-app.
 *
 * phone-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * phone-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
var sectionData = [];
var _sections = [];

function sectionValueForContact(contact) {
    if (contact) {
        var section = contact.tag.tag.charAt(0).toUpperCase()
        return (section === "" ? "#" : section)
    } else {
        return null
    }
}

function initSectionData(list) {
    if (!list || !list.listModel) {
        return;
    }

    sectionData = [];
    _sections = [];

    var current = "";
    var item;
    var contacts = list.listModel.contacts;

    for (var i = 0, count = contacts.length; i < count; i++) {
        item = sectionValueForContact(contacts[i])
        if (item !== current) {
            current = item;
            _sections.push(current);
            sectionData.push({ index: i, header: current});
        }
    }
}

function getIndexFor(sectionName) {
    var index = _sections.indexOf(sectionName)
    if (index != -1) {
        var val = sectionData[_sections.indexOf(sectionName)].index;
        return val === 0 || val > 0 ? val : -1;
    } else {
        return -1
    }
}
