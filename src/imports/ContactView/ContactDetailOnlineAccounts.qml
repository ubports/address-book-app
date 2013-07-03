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

ContactDetailGroupWithAction {
    function getTypeIndex(detail) {
        return detail.value(2)
    }

    title: i18n.tr("IM")
    details: contactEditor.contact ? contactEditor.contact.details(QtContacts.ContactDetail.OnlineAccount) : null
    fields: [ QtContacts.OnlineAccount.AccountUri ]

    typeModel: ListModel {
        Component.onCompleted: {
            append({"value": 0, "label": i18n.tr("Other"), icon: "artwork:/protocol-other.png"})
            append({"value": 1, "label": i18n.tr("Aim"), icon: "artwork:/protocol-aim.png"})
            append({"value": 2, "label": i18n.tr("ICQ"), icon: "artwork:/protocol-icq.png"})
            append({"value": 3, "label": i18n.tr("IRC"), icon: "artwork:/protocol-irc.png"})
            append({"value": 4, "label": i18n.tr("Jabber"), icon: "artwork:/protocol-jabber.png"})
            append({"value": 5, "label": i18n.tr("MSN"), icon: "artwork:/protocol-msn.png"})
            append({"value": 6, "label": i18n.tr("QQ"), icon: "artwork:/protocol-qq.png"})
            append({"value": 7, "label": i18n.tr("Skype"), icon: "artwork:/protocol-skype.png"})
            append({"value": 8, "label": i18n.tr("Yahoo"), icon: "artwork:/protocol-yahoo.png"})
        }
    }
}
