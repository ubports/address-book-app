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

.import QtContacts 5.0 as QtContacts

var detailsSubTypes = [ { value: "Home", label: i18n.tr("Home") },
                        { value: "Work", label: i18n.tr("Work") },
                        { value: "Other", label: i18n.tr("Other") } ];

var phoneSubTypes = [ { value: "Mobile", label: i18n.tr("Mobile") },
                      { value: "Home", label: i18n.tr("Home") },
                      { value: "Work", label: i18n.tr("Work") },
                      { value: "Other", label: i18n.tr("Other") } ];

var emailSubTypes = detailsSubTypes;
var postalAddressSubTypes = detailsSubTypes;

/* We are using the int values here until we get this bug fixed: https://bugreports.qt-project.org/browse/QTBUG-32142
 * then we can change it to the correct enums
 */
var IMSubTypes = [ { value: 0, label: i18n.tr("Other"), icon: "protocol_other.png" },
                   { value: 1, label: i18n.tr("Aim"), icon: "protocol_aim.png" },
                   { value: 2, label: i18n.tr("ICQ"), icon: "protocol_icq.png" },
                   { value: 3, label: i18n.tr("IRC"), icon: "protocol_irc.png" },
                   { value: 4, label: i18n.tr("Jabber"), icon: "protocol_jabber.png" },
                   { value: 5, label: i18n.tr("MSN"), icon: "protocol_msn.png" },
                   { value: 6, label: i18n.tr("QQ"), icon: "protocol_qq.png" },
                   { value: 7, label: i18n.tr("Skype"), icon: "protocol_skype.png" },
                   { value: 8, label: i18n.tr("Yahoo"), icon: "protocol_yahoo.png" } ];


function getDetailSubType(detail) {
    if (!detail) {
        return "";
    }

    /* Phone numbers have a special field for the subType */
    if (detail.type === QtContacts.ContactDetail.PhoneNumber) {
        if (detail.contexts.indexOf(QtContacts.ContactDetail.ContextHome) > -1) {
            return phoneSubTypes[1];
        } else if (detail.contexts.indexOf(QtContacts.ContactDetail.ContextWork) > -1) {
            return phoneSubTypes[2];
        } else if (detail.subTypes.indexOf(QtContacts.ContactPhoneNumber.Mobile) > -1) {
            return phoneSubTypes[0];
        }
        return phoneSubTypes[3];
    } else if (detail.type === QtContacts.ContactDetail.OnlineAccount) {
        return IMSubTypes[detail.value(2)];
    } else if (detail.type === QtContacts.ContactDetail.Address) {
        var contexts = detail.contexts;
        if (contexts.indexOf(QtContacts.ContactDetail.ContextHome) > -1) {
            return detailsSubTypes[0];
        } else if (contexts.indexOf(QtContacts.ContactDetail.ContextWork) > -1) {
            return detailsSubTypes[1];
        } else {
            return detailsSubTypes[2];
        }
    } else {
        // The backend supports multiple types but we can just handle one,
        // so let's pick just the first
        var context = -1;
        for (var i = 0; i < detail.contexts.length; i++) {
            context = detail.contexts[i];
            break;
        }
        var subType = -1;
        // not all details have subTypes
        if (detail.subTypes) {
            for (var i = 0; i < detail.subTypes.length; i++) {
                subType = detail.subTypes[i];
                break;
            }
        }

        if (context === QtContacts.ContactDetail.ContextHome) {
            return detailsSubTypes[0];
        } else if (context === QtContacts.ContactDetail.ContextWork) {
            return detailsSubTypes[1];
        } else if (subType === QtContacts.ContactDetail.ContextOther) {
            return detailsSubTypes[2];
        }
    }

    return detailsSubTypes[2];
}
