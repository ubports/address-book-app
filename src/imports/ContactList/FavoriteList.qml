import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1

import "../Components"

Item {
    property alias count: view.count

    ContactModel {
        id: favoriteModel

        manager: "galera"
        sortOrders: [
            SortOrder {
                id: sortOrder

                detail: ContactDetail.Name
                field: Name.FirstName
                direction: Qt.AscendingOrder
            }
        ]

        fetchHint: FetchHint {
            detailTypesHint: [ContactDetail.Avatar, ContactDetail.Name, ContactDetail.PhoneNumber ]
        }
    }

    OrganicView {
        id: view

        bigSize: units.gu(17)
        smallSize: units.gu(11)
        margin: units.gu(1)
        model: favoriteModel
        anchors.fill: parent

        delegate: UbuntuShape {
            id: img
            property var contact: model ? model.contact : null
            anchors.fill: parent

            image: Image {
                source: img.contact.avatar && (img.contact.avatar.imageUrl != "") ?  Qt.resolvedUrl(img.contact.avatar.imageUrl) : "artwork:/avatar-default.png"
                asynchronous: true
            }

            Rectangle {
                id: bgLabel

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: units.gu(5)
                color: "black"
                opacity: 0.7
            }

            Label {
                id: contactName

                anchors {
                    left: bgLabel.left
                    leftMargin: units.gu(1.0)
                    top: bgLabel.top
                    topMargin: units.gu(0.5)
                    right: bgLabel.right
                }
                height: units.gu(2.5)
                verticalAlignment: Text.AlignVCenter
                text: contact.name ? contact.name.firstName + " " + contact.name.lastName : ""
                elide: Text.ElideRight
                color: "white"
            }

            Label {
                id: contactPhoneLabel

                anchors {
                    left: contactName.left
                    top: contactName.bottom
                    right: contactName.right
                }
                height: units.gu(1)
                verticalAlignment:  Text.AlignVCenter
                text: contact.phoneNumber.number
                elide: Text.ElideRight
                fontSize: "small"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../ContactView/ContactView.qml"),
                                   {model: favoriteModel, contactId: contact.contactId})
                }
            }
        }
    }
}
