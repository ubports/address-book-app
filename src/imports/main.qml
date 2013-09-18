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
import QtContacts 5.0
import Ubuntu.Components 0.1

MainView {
    id: mainView

    width: units.gu(40)
    height: units.gu(71)
    anchorToKeyboard: true

    signal applicationReady()

    function contact(contactId) {
        mainStack.contactRequested(contactId)
    }

    function create(phoneNumber) {
        mainStack.createContactRequested(phoneNumber)
    }

    function addphone(contactId, phoneNumber) {
        mainStack.newPhoneNumber = phoneNumber
        mainStack.editContatRequested(contactId, phoneNumber)
    }

    PageStack {
        id: mainStack

        property string newPhoneNumber: ""

        signal contactRequested(string contactId)
        signal createContactRequested(string phoneNumber)
        signal editContatRequested(string contactId, string phoneNumber)

        anchors {
            fill: parent
            Behavior on bottomMargin {
                NumberAnimation {
                    duration: 175
                    easing.type: Easing.OutQuad
                }
            }
       }
    }

    Component.onCompleted: {
        Theme.name = "Ubuntu.Components.Themes.SuruGradient"
        mainStack.push(Qt.createComponent("ContactList/ContactListPage.qml"))
        mainView.applicationReady()
    }
}
