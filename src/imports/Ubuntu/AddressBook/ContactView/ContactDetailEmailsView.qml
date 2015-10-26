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
import Ubuntu.Components 1.3

ContactDetailGroupWithTypeView {
    id: root

    detailType: QtContacts.ContactDetail.Email
    title: i18n.dtr("address-book-app", "Email")
    fields: [ 0 ]
    defaultAction: Action {
        text: i18n.dtr("address-book-app", "Email")
        name: "mailto"
        iconName: "email"
    }
}
