/****************************************************************************
**
** Copyright (C) 2013 Canonical Ltd
**
****************************************************************************/

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
                    subtitle.text: DetailTypes.getDetailSubType(detail).value
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
                    subtitle.text: DetailTypes.getDetailSubType(detail).value
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
                    subtitle.text: DetailTypes.getDetailSubType(detail).value
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
                    subtitle.text: DetailTypes.getDetailSubType(detail).value
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
