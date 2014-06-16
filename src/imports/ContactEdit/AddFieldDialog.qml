/*
 * Copyright (C) 2012-2014 Canonical, Ltd.
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
import Ubuntu.Components 0.1
import QtContacts 5.0
import Ubuntu.Components.Popups 0.1 as Popups


Item {
    id: root

    property QtObject contact: null
    property var currentDialog: null
    readonly property var validDetails: [ ContactDetail.PhoneNumber,
                                          ContactDetail.Email,
                                          ContactDetail.Address,
                                          ContactDetail.OnlineAccount,
                                          ContactDetail.Organization
                                          // TODO: Not supported yet
                                          // ContactDetail.Birthday,
                                          // ContactDetail.Note,
                                          // ContactDetail.Url
                                         ]
    readonly property var singleValueDetails: [ ContactDetail.Organization ]
    signal fieldSelected(string fieldName, string qmlTypeName)

    function showOptions()
    {
        if (currentDialog == null) {
            // make sure the OSK disappear
            root.forceActiveFocus()
            currentDialog = PopupUtils.open(addFieldDialog, null)
        }
    }

    function nameFromEnum(value)
    {
        switch (value)
        {
        case ContactDetail.PhoneNumber:
            return i18n.tr("Phone")
        case ContactDetail.Email:
            return i18n.tr("Email")
        case ContactDetail.Address:
            return i18n.tr("Address")
        case ContactDetail.OnlineAccount:
            return i18n.tr("Social")
        case ContactDetail.Organization:
            return i18n.tr("Profissional Details")
        default:
            console.error("Invalid contact detail enum value:" + value)
            return ""
        }
    }

    function qmlTypeFromEnum(value)
    {
        switch (value)
        {
        case ContactDetail.PhoneNumber:
            return "PhoneNumber"
        case ContactDetail.Email:
            return "EmailAddress"
        case ContactDetail.Address:
            return "Address"
        case ContactDetail.OnlineAccount:
            return "OnlineAccount"
        case ContactDetail.Organization:
            return "Organization"
        default:
            console.error("Invalid contact detail enum value:" + value)
            return ""
        }
    }

    // check which details will be allowed to create
    // some details we only support one value
    function filterSingleDetails(details, contact)
    {
        var result = []
        for(var i=0; i < details.length; i++) {
            var det = details[i]
            if (singleValueDetails.indexOf(det) != -1) {
                if (contact.details(det).length === 0) {
                    result.push(det)
                }
            } else {
                result.push(det)
            }
        }
        return result
    }

    visible: false
    Component {
        id: addFieldDialog

        Popups.Dialog {
            id: dialogue

            title: i18n.tr("Select a field")
            Repeater {
                model: root.filterSingleDetails(validDetails, root.contact)
                Button {
                    text: root.nameFromEnum(modelData)
                    onClicked: {
                        root.fieldSelected(text, root.qmlTypeFromEnum(modelData))
                        PopupUtils.close(root.currentDialog)
                        root.currentDialog = null
                    }
                }
            }
            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(root.currentDialog)
                    root.currentDialog = null
                }
            }
        }
    }
}
