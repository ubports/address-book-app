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
import Ubuntu.Components 0.1

//style
import Ubuntu.Components.Themes.Ambiance 0.1

TextField {
    id: root

    property QtObject detail
    property int field: -1
    property variant originalValue: root.detail && (root.field >= 0) ? root.detail.value(root.field) : null

    // phone number mask
    // If mask is enabled we will try format the phone number based on the number of digits
    // From 5 to 8 digits = ####-####
    // More than 8 digits = ## ####-####
    // The format mask can be changed by localization strings
    property bool useMask: false
    // TRANSLATORS: This regex is used to detect small phone number format, if true the small format mask will be used
    readonly property string regexSmall: i18n.tr("^\\d{5}$")
    // TRANSLATORS: This small mask will be applied for phones that match with small regex
    readonly property string formatSmall: i18n.tr("####-#")
    // TRANSLATORS: This regex is used to detect long phone number format, if true the long format mask will be used
    readonly property string regexLong: i18n.tr("^\\d{4}-\\d{5}$")
    // TRANSLATORS: This small mask will be applied for phones that match with long regex
    readonly property string formatLong: i18n.tr("## ####-#")

    property var formatSmallDetails: null
    property var formatLongDetails: null

    function parseMask(mask) {
        var start = 0;
        var maskDetails = []

        for(var i=0; i < mask.length; i++) {
            console.debug("Check for:", mask[i])
            if (mask[i] !== "#") {
                if (start != i) {
                    maskDetails.push({"text": "#",
                                      "start": start,
                                      "end": i})
                }
                maskDetails.push({"text": mask[i],
                                  "start": i,
                                  "end": i})
                start = i
            }
        }

        if (start < mask.length) {
            maskDetails.push({"text": "#",
                              "start": start,
                              "end": mask.length})
        }

        return maskDetails
    }

    function formatValue(value, maskDetails) {
        var formatedValue = ""
        var numbers = value.replace(/\D+/g,"")

        for(var i=0; i < maskDetails.length; i++) {
            var maskPart = maskDetails[i]
            if (maskPart.text === "#") {
                formatedValue += numbers.substring(maskPart.start, maskPart.end)
            } else {
                formatedValue += maskPart.text
            }
        }

        return formatedValue
    }


    signal removeClicked()

    Component.onCompleted: {
        makeMeVisible(root)
        if (useMask) {
            formatSmallDetails = parseMask(formatSmall)
            formatLongDetails = parseMask(formatLong)
        }
    }

    readOnly: detail ? detail.readOnly : true
    focus: true
    text: originalValue ? originalValue : ""
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

    onTextChanged: {
        if (!useMask) {
            return
        }
        var regexSmallObj = new RegExp(regexSmall)
        var regexLongObj = new RegExp(regexLong)

        if (regexSmallObj.test(text)) {
            text = formatValue(text, formatSmallDetails)
        } else if (regexLongObj.test(text)) {
            text = formatValue(text, formatLongDetails)
        }
    }

    // default style
    font {
        family: "Ubuntu"
        pixelSize: activeFocus ? FontUtils.sizeToPixels("large") : FontUtils.sizeToPixels("medium")
    }
}
