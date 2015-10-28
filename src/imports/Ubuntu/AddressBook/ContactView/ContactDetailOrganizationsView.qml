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

import QtQuick 2.4
import QtContacts 5.0 as QtContacts


ContactDetailGroupWithTypeView {
    id: root

    title: i18n.dtr("address-book-app", "Professional Details")
    defaultIcon: "image://theme/location"
    detailType: QtContacts.ContactDetail.Organization
    typeModel: null

    fields: [ QtContacts.Organization.Name,
              QtContacts.Organization.Role,
              QtContacts.Organization.Title ]
}
