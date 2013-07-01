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

import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "DetailTypeUtilities.js" as DetailTypes

Page {
    id: contactEditor

    property variant contact: null
    property variant model: null

    Flickable {
        flickableDirection: Flickable.VerticalFlick
        anchors.fill: parent
        contentHeight: contents.height
        contentWidth: parent.width

        Column {
            id: contents

            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            ContactHeader {
                contact: contactEditor.contact
                width: parent.width
                height: units.gu(12)
            }

            ContactDetailGroup {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight

                title: "Phone"
                details: contactEditor.contact ? contactEditor.contact.phoneNumbers : null
                view: ContactDetailViewWithAction {
                    fields: [ PhoneNumber.Number ]
                    subtitle.text: DetailTypes.getDetailSubType(detail).label
                    actionIcon: "artwork:/contact-call.png"
                    height: implicitHeight
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
            }

            ContactDetailGroup {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
                title: "Email"
                details: contactEditor.contact ? contactEditor.contact.emails : null
                view: ContactDetailViewWithAction {
                    fields: [ 0 ]
                    subtitle.text: DetailTypes.getDetailSubType(detail).label
                    actionIcon: "artwork:/contact-email.png"
                    height: implicitHeight
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
            }

            ContactDetailGroup {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
                title: "IM"
                //TODO: implement support for onlineAccount list in QtPim
                details: contactEditor.contact ? contactEditor.contact.details(ContactDetail.OnlineAccount) : null
                view: ContactDetailViewWithAction {
                    fields: [ OnlineAccount.AccountUri ]
                    subtitle.text: DetailTypes.getDetailSubType(detail).label
                    //TODO: parse protocol name into a icon name
                    actionIcon: "artwork:/contact-email.png"
                    height: implicitHeight
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
            }

            ContactDetailGroup {
                contact: contactEditor.contact
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(1)
                }
                height: implicitHeight
                title: "Address"
                details: contactEditor.contact ? contactEditor.contact.addresses : null
                view: ContactDetailViewWithAction {
                    fields: [Address.Street, Address.Locality, Address.Region, Address.Postcode, Address.Country]
                    subtitle.text: DetailTypes.getDetailSubType(detail).label
                    actionIcon: "artwork:/contact-location.png"
                    height: implicitHeight
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                }
            }
        }
    }
}
