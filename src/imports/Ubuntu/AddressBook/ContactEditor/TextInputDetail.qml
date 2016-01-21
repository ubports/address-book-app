/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
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
import Ubuntu.Components 1.3
import Ubuntu.Keyboard 0.1
import Ubuntu.Telephony.PhoneNumber 0.1

//style
import Ubuntu.Components.Themes.Ambiance 0.1

FocusScope {
    id: root

    //WORKAROUND: SDK does not allow us to disable focus for items due bug: #1514822
    //because of that we need this
    readonly property bool _allowFocus: true
    readonly property bool isTextField: true

    property QtObject detail
    property int field: -1
    property variant originalValue: root.detail && (root.field >= 0) ? root.detail.value(root.field) : null

    // proxy textField
    property alias font: field.font
    property alias placeholderText: field.placeholderText
    property alias inputMethodHints: field.inputMethodHints
    property alias text: field.text
    property alias hasClearButton: field.hasClearButton
    // proxy PhoneNumberField
    property alias autoFormat: field.autoFormat

    signal removeClicked()

    //FIXME: Move this property to TextField as soon as the SDK get ported to QtQuick 2.2
    activeFocusOnTab: true
    onOriginalValueChanged: {
        if (originalValue && (originalValue !== "")) {
            field.text = originalValue
        }
    }

    // propage focus to text field
    onActiveFocusChanged: {
        if (activeFocus)
            field.forceActiveFocus()
    }

    PhoneNumberField {
        id: field

        //WORKAROUND: Due the SDK bug #1514822, #1514850 we can not disable focus for some items
        //because of that we keep the focus only for textFields. This will block the user
        //to use keyboard on "add-field" combo box and some other functionalities
        function forceActiveFocusForNextField(keyEvent)
        {
            var backward = (keyEvent.modifiers & Qt.ShiftModifier)
            var next = field.nextItemInFocusChain(!backward)
            // only focus on TextInputDetails
            while (!next || !next.hasOwnProperty("isTextField")) {
                next = next.nextItemInFocusChain(!backward)
            }
            if (next) {
                next.forceActiveFocus()
            }
        }

        anchors.fill: parent
        defaultRegion: PhoneUtils.defaultRegion
        autoFormat: false

        // Ubuntu.Keyboard
        // TRANSLATORS: This is the text that will be used on the "return" key for the virtual keyboard,
        // this word must be less than 5 characters
        InputMethod.extensions: { "enterKeyText": i18n.dtr("address-book-app", "Next") }
        readOnly: root.detail ? root.detail.readOnly : true
        style: TextFieldStyle {
            overlaySpacing: 0
            frameSpacing: 0
            background: Item {}
        }
        onActiveFocusChanged: {
            if (activeFocus) {
                makeMeVisible(root)
            }
        }

        // default style
        font {
            family: "Ubuntu"
            pixelSize: activeFocus ? FontUtils.sizeToPixels("large") : FontUtils.sizeToPixels("medium")
        }

        Keys.onReturnPressed: forceActiveFocusForNextField(event)
        Keys.onTabPressed: forceActiveFocusForNextField(event)
        Keys.onBacktabPressed: forceActiveFocusForNextField(event)
    }
}
