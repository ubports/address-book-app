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

import QtQuick 2.2
import QtContacts 5.0

ContactDetailGroupWithTypeEditor {
    title: i18n.tr("Professional Details")
    typeModel: null
    detailQmlTypeName: "Organization"
    detailType: ContactDetail.Organization
    fields: [ Organization.Name,
              Organization.Role,
              Organization.Title ]
    placeholderTexts: [ i18n.tr("Organization"),
                        i18n.tr("Role"),
                        i18n.tr("Title")
                      ]
    inputMethodHints: Qt.ImhNoPredictiveText
}
