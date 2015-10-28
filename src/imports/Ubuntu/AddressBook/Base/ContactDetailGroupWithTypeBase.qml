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
import QtContacts 5.0 as QtContacts

ContactDetailGroupBase {
    id: root

    property string defaultIcon : "artwork:/protocol-other.png"
    property ListModel typeModel
    property bool typeModelReady: false

    function getType(detail) {
        if (typeModel) {
            return typeModel.get(typeModel.getTypeIndex(detail))
        } else {
            return ""
        }
    }

    function updateDetail(detail, index) {
        if (typeModel) {
            return typeModel.updateDetail(detail, index)
        }
        return false
    }

    typeModel: ListModel {
        signal loaded()

        function getTypeIndex(detail) {
            var context = -1;
            for (var i = 0; i < detail.contexts.length; i++) {
                context = detail.contexts[i];
                break;
            }
            var subType = -1;
            // not all details have subTypes
            if (detail.subTypes) {
                for (var i = 0; i < detail.subTypes.length; i++) {
                    subType = detail.subTypes[i];
                    break;
                }
            }
            if (context === QtContacts.ContactDetail.ContextHome) {
                return 0
            } else if (context === QtContacts.ContactDetail.ContextWork) {
                return 1
            } else if (context === QtContacts.ContactDetail.ContextOther) {
                return 2
            } else {
                return 0 // default value is "Home"
            }
        }

        function isNotAModelValue(value) {
            for(var i=0; i < count; i++) {
                if (value === get(i).value) {
                    return false
                }
            }
            return true
        }

        function compareList(listA, listB) {
            if (!listA && !listB) {
                return true
            }

            if (!listA || !listB) {
                return false
            }

            if (listA.length != listB.length) {
                return false
            }
            for(var i=0; i < listA.length; i++) {
                if (listA[i] != listB[i]) {
                    return false
                }
            }
            return true
        }

        function updateDetail(detail, index) {
            var modelData = get(index)
            if (!modelData) {
                return false
            }

            var newContext = detail.contexts.filter(isNotAModelValue)
            newContext.push(modelData.value)
            if (!compareList(newContext, detail.contexts)) {
                detail.contexts = newContext
                return true
            }
            return false
        }

        Component.onCompleted: {
            append({"value": QtContacts.ContactDetail.ContextHome,
                    "label": i18n.dtr("address-book-app", "Home"),
                    "icon": null})
            append({"value": QtContacts.ContactDetail.ContextWork,
                    "label": i18n.dtr("address-book-app", "Work"),
                    "icon": null})
            append({"value": QtContacts.ContactDetail.ContextOther,
                    "label": i18n.dtr("address-book-app", "Other"),
                    "icon": null})
            loaded()
        }
    }
    onTypeModelChanged: root.typeModelReady = false
    Connections {
        target: root.typeModel
        onLoaded: root.typeModelReady = true
    }
}
