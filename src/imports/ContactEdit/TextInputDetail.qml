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

import QtQuick 2.2
import Ubuntu.Components 0.1
import Ubuntu.Keyboard 0.1
import Ubuntu.Telephony.PhoneNumber 0.1

//style
import Ubuntu.Components.Themes.Ambiance 0.1

PhoneNumberField {
    id: root

    property QtObject detail
    property int field: -1
    property variant originalValue: root.detail && (root.field >= 0) ? root.detail.value(root.field) : null

    signal removeClicked()

    // TRANSLATORS: This value is used as default value for phone number format, when no coutry code is provided
    // the supported values can be found in: https://www.iso.org/obp/ui/#search
    defaultRegion: i18n.tr("US")
    autoFormat: false

    // Ubuntu.Keyboard
    InputMethod.extensions: { "enterKeyText": i18n.tr("Next") }

    readOnly: detail ? detail.readOnly : true
    focus: true
    text: originalValue ? originalValue : ""
    style: TextFieldStyle {
        overlaySpacing: 0
        frameSpacing: 0
        background: Item {}
    }

    Component.onCompleted: makeMeVisible(root)
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

    Keys.onReturnPressed: application.sendTabEvent();
}
