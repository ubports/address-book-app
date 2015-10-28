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

ListModel {
    id: typeModel

    signal loaded()

    function getTypeIndex(detail) {
        var protocol = detail.value(2)
        switch(protocol) {
        case 1:
            return 0;
        case 2:
            return 1;
        case 4:
            return 2;
        case 5:
            return 3;
        case 7:
            return 4;
        case 8:
            return 5;
        default:
            return 4; //default value is "Skype"
        }
    }

    function updateDetail(detail, index) {
        var modelData = get(index)
        if (!modelData) {
            return false
        }

        if (detail.value(2) != modelData.value) {
            detail.setValue(2, modelData.value)
            return true
        }

        return false
    }

    Component.onCompleted: {
        //append({"value": 0, "label": i18n.dtr("address-book-app", "Other"), icon: "artwork:/protocol-other.svg"})
        /*0*/ // TRANSLATORS: This refers to the AIM chat network http://en.wikipedia.org/wiki/AOL_Instant_Messenger
                append({"value": 1, "label": i18n.dtr("address-book-app", "Aim"), "icon": "artwork:/protocol-aim.svg"})
        /*1*/   append({"value": 2, "label": i18n.dtr("address-book-app", "ICQ"), "icon": "artwork:/protocol-icq.svg"})
        //append({"value": 3, "label": i18n.dtr("address-book-app", "IRC"), icon: "artwork:/protocol-irc.svg"})
        /*2*/   append({"value": 4, "label": i18n.dtr("address-book-app", "Jabber"), "icon": "artwork:/protocol-jabber.svg"})
        /*3*/   append({"value": 5, "label": i18n.dtr("address-book-app", "MSN"), "icon": "artwork:/protocol-msn.svg"})
        // append({"value": 6, "label": i18n.dtr("address-book-app", "QQ"), icon: "artwork:/protocol-qq.svg"})
        /*4*/   append({"value": 7, "label": i18n.dtr("address-book-app", "Skype"), "icon": "artwork:/protocol-skype.svg"})
        /*5*/   append({"value": 8, "label": i18n.dtr("address-book-app", "Yahoo"), "icon": "artwork:/protocol-yahoo.svg"})
        loaded()
    }
}
