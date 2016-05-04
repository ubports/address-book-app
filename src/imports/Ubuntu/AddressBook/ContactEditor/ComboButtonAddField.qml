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

import QtQuick 2.4
import QtContacts 5.0

import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3

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
    readonly property var specialFields: {
        "CONTACT_DETAIL_MIDDLE_NAME": 1000
    }

    signal fieldSelected(string fieldName, string qmlTypeName)
    signal specialFieldSelected(string fieldName, int type)

    function nameFromEnum(value)
    {
        switch (value)
        {
        case ContactDetail.PhoneNumber:
            return i18n.dtr("address-book-app", "Phone")
        case ContactDetail.Email:
            return i18n.dtr("address-book-app", "Email")
        case ContactDetail.Address:
            return i18n.dtr("address-book-app", "Address")
        case ContactDetail.OnlineAccount:
            return i18n.dtr("address-book-app", "Social")
        case ContactDetail.Organization:
            return i18n.dtr("address-book-app", "Professional Details")
        // special cases
        case root.specialFields.CONTACT_DETAIL_MIDDLE_NAME:
            return i18n.dtr("address-book-app", "Middle Name")
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
            // Handle special cases
            // MiddleName: Only allow to add middle name if the field is empty
            var nameDet = contact.detail(ContactDetail.Name)
            if (nameDet && (nameDet.value(Name.MiddleName) === undefined)) {
                result.push(root.specialFields.CONTACT_DETAIL_MIDDLE_NAME)
            }

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

    collapsedHeight: units.gu(4)
    implicitHeight: expanded ? expandedHeight : collapsedHeight
    onClicked: expanded = !expanded

    // make sure that the signal will be fired after the item collapse
    onHeightChanged: {
        if (!expanded && (selectedDetail !== -1) && (height === collapsedHeight)) {
            if (root.selectedDetail >= root.specialFields.CONTACT_DETAIL_MIDDLE_NAME)
                root.specialFieldSelected(root.nameFromEnum(root.selectedDetail), root.selectedDetail)
            else
                root.fieldSelected(root.nameFromEnum(root.selectedDetail), root.qmlTypeFromEnum(root.selectedDetail))
            root.selectedDetail = -1
            view.model = root.filterSingleDetails(validDetails, root.contact)
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
