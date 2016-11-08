/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
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
import Ubuntu.Components.Popups 1.3
import Ubuntu.Contacts 0.1 as ContactsUI

Dialog {
    id: alertMessageDialog

    property QtObject contact: null
    signal destruction

    title: i18n.dtr("address-book-app", "Contact Editor")
    text: {
        if (ContactsUI.Contacts.updateIsRunning) {
            return i18n.dtr("address-book-app",
                            "Your <b>%1</b> contact sync account needs to be upgraded.\nWait until the upgrade is complete to edit contacts.")
                            .arg(alertMessageDialog.contact.syncTarget.syncTarget)
        }
        if (Qt.application.name === "AddressBookApp") {
              i18n.dtr("address-book-app",
                       "Your <b>%1</b> contact sync account needs to be upgraded. Use the sync button to upgrade the Contacts app.\nOnly local contacts will be editable until upgrade is complete.")
                .arg(alertMessageDialog.contact.syncTarget.syncTarget)
        } else {
              i18n.dtr("address-book-app",
                       "Your <b>%1</b> contact sync account needs to be upgraded by running Contacts app.\nOnly local contacts will be editable until upgrade is complete.")
                .arg(alertMessageDialog.contact.syncTarget.syncTarget);
        }
    }

    Button {
        text: i18n.dtr("address-book-app", "Close")
        onClicked: PopupUtils.close(alertMessageDialog)
    }

    Component.onCompleted: Qt.inputMethod.hide()
}
