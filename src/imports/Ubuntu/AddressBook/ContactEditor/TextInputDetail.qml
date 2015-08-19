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

import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Keyboard 0.1
import Ubuntu.Telephony.PhoneNumber 0.1

//style
import Ubuntu.Components.Themes.Ambiance 0.1

FocusScope {
    id: root

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

    // WORKAROUND: For some reason TextField.focus property get reset to false
    // we need do a deep investigation on that
    Binding {
        target: field
        property: "focus"
        value: visible
    }

    onActiveFocusChanged:  {
        if (activeFocus && field.visible) {
            field.forceActiveFocus()
        }
    }

    onOriginalValueChanged: {
        if (originalValue && (originalValue !== "")) {
            field.text = originalValue
        }
    }

    PhoneNumberField {
        id: field

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
            color: UbuntuColors.lightAubergine
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
        Keys.onReturnPressed: {
            var next = field.nextItemInFocusChain(true)
            // only focus on TextInputDetails
            while (!next || !next.hasOwnProperty("isTextField")) {
                next = next.nextItemInFocusChain(true)
            }
            if (next) {
                next.forceActiveFocus()
            }
        }
    }
}
