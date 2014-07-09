/*
 * Copyright (C) 2014 Canonical, Ltd.
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

function createContact(detailsMap, parent) {
    var newContact = Qt.createQmlObject(
        'import QtContacts 5.0; Contact{ }', parent);
    var detailSourceTemplate = 'import QtContacts 5.0; %1{ %2: "%3" }';
    for (var i=0; i < detailsMap.length; i++) {
        var detailMetaData = detailsMap[i];
        var template = detailSourceTemplate.arg(detailMetaData.detail).arg(
            detailMetaData.field).arg(detailMetaData.value);
        var newDetail = Qt.createQmlObject(template, parent);
        newContact.addDetail(newDetail);
    }
    return newContact;
}
