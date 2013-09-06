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

    property variant headerObject: null
    property int headerDefaultHeight: 0

    signal applicationReady()

    function contact(contactId) {
        mainStack.contactRequested(contactId)
    }

    // WORKAROUND: help function to retrieve the header element
    function create(phoneNumber) {
        mainStack.createContactRequested(phoneNumber)
    }

    function findHeader(parent) {
        var childList = parent.children
        for(var i=0; i < childList.length; i++) {
            var child = childList[i]
            if (child.objectName == "MainView_Header") {
                return child
            } else {
                var header = findHeader(child)
                if (header) {
                    return header
                }
            }
        }
        return null
    }

    function updateHeader() {
        headerObject = findHeader(mainView)
        if (headerObject) {
            headerDefaultHeight = headerObject.height
        }
    }

    width: units.gu(40)
    height: units.gu(71)
    anchorToKeyboard: true

    PageStack {
        id: mainStack

        property bool showHeader: true

        signal contactRequested(string contactId)
        signal createContactRequested(string phoneNumber)

        onShowHeaderChanged: {
            if (mainView.headerObject && showHeader) {
                mainView.headerObject.height =  mainView.headerDefaultHeight
                mainView.headerObject.visible = true
                mainView.headerObject.hide()
            } else {
                mainView.headerObject.height = 0
                mainView.headerObject.visible = false
            }
        }

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

        // WORKAROUND: we need to hide the header due a bug on SDK
        // but the header object is not public on the main view because of that
        // wee need to search for the objectName.
        updateHeader()
    }
}
