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
import QtContacts 5.0

import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0

ComboButton {
    id: root

    property QtObject contact: null
    property int selectedDetail: -1
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
            return i18n.tr("Professional Details")
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
        if (contact) {
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
        }
        return result
    }

    collapsedHeight: units.gu(5)
    implicitHeight: expanded ? expandedHeight : collapsedHeight
    onClicked: expanded = !expanded

    // make sure that the signal will be fired after the item collapse
    onHeightChanged: {
        if (!expanded && (selectedDetail !== -1) && (height === collapsedHeight)) {
            fieldSelected(root.nameFromEnum(selectedDetail), root.qmlTypeFromEnum(selectedDetail))
            selectedDetail = -1
        }
    }

    ListView {
        id: view
        objectName: "listViewOptions"

        model: root.filterSingleDetails(validDetails, root.contact)
        delegate: Standard {
            objectName: text
            text: root.nameFromEnum(modelData)
            onClicked: {
                root.selectedDetail = modelData
                root.expanded = false
            }
        }
    }
}
