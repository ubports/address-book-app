/*
 * Copyright (C) 2012-2013 Canonical, Ltd.
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
import QtContacts 5.0 as QtContacts

ContactDetailGroupWithTypeView {
    title: i18n.tr("Address")
    defaultIcon: "artwork:/contact-location.png"
    detailType: QtContacts.ContactDetail.Address
    fields: [ QtContacts.Address.Street,
              QtContacts.Address.Locality,
              QtContacts.Address.Region,
              QtContacts.Address.Postcode,
              QtContacts.Address.Country]
}
