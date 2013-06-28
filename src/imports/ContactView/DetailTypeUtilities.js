/*
 * Copyright 2012-2013 Canonical Ltd.
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

.import QtContacts 5.0 as QtContacts

var PROTOCOL_LABEL_AIM      = "AIM";
var PROTOCOL_LABEL_MSN      = "Windows Live";
var PROTOCOL_LABEL_YAHOO    = "Yahoo";
var PROTOCOL_LABEL_SKYPE    = "Skype";
var PROTOCOL_LABEL_QQ       = "QQ";
var PROTOCOL_LABEL_GTALK    = "Google Talk";
var PROTOCOL_LABEL_ICQ      = "ICQ";
var PROTOCOL_LABEL_JABBER   = "Jabber";
var PROTOCOL_LABEL_OTHER    = "Other";

var PROTOCOL_TYPE_CUSTOM    = "im";
var PROTOCOL_TYPE_AIM       = "aim";
var PROTOCOL_TYPE_MSN       = "msn";
var PROTOCOL_TYPE_YAHOO     = "yahoo";
var PROTOCOL_TYPE_SKYPE     = "skype";
var PROTOCOL_TYPE_GTALK     = "google_talk";
var PROTOCOL_TYPE_ICQ       = "icq";
var PROTOCOL_TYPE_JABBER    = "jabber";
var PROTOCOL_TYPE_OTHER     = "other";

var detailsSubTypes = [ { value: "Home", label: i18n.tr("Home") },
                        { value: "Work", label: i18n.tr("Work") },
                        { value: "Other", label: i18n.tr("Other") } ];

var phoneSubTypes = [ { value: "Mobile", label: i18n.tr("Mobile") },
                      { value: "Home", label: i18n.tr("Home") },
                      { value: "Work", label: i18n.tr("Work") },
                      { value: "Other", label: i18n.tr("Other") } ];

var emailSubTypes = detailsSubTypes;
var postalAddressSubTypes = detailsSubTypes;


var IMSubTypes = [ { value: PROTOCOL_LABEL_GTALK, label: i18n.tr("Google Talk") },
                   { value: PROTOCOL_LABEL_YAHOO, label: i18n.tr("Yahoo") },
                   { value: PROTOCOL_LABEL_SKYPE, label: i18n.tr("Skype") },
                   { value: PROTOCOL_LABEL_OTHER, label: i18n.tr("Other") } ]

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
        var protocol = detail.serviceProvider;
        console.debug("Provider:" + protocol)
        if (protocol === PROTOCOL_TYPE_YAHOO) {
            return IMSubTypes[1];
        } else if (protocol === PROTOCOL_TYPE_SKYPE) {
            return IMSubTypes[2];
        } else if (protocol === PROTOCOL_TYPE_GTALK) {
            return IMSubTypes[0];
        } else {
            return IMSubTypes[3];
        }
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
