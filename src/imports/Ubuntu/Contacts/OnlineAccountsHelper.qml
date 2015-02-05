/*
 * Copyright (C) 2014 Canonical, Ltd.
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
import Ubuntu.OnlineAccounts 0.1
import Ubuntu.OnlineAccounts.Client 0.1

Item {
    id: root

    readonly property bool hasContactAccounts: (accounts.count > 0)

    function setupExec()
    {
         setup.exec()
    }

    AccountServiceModel {
        id: accounts
        applicationId: "contacts-sync"
        onCountChanged: {
            if (count > 0) {
                root.closeDialog()
            }
        }
    }

    Setup {
        id: setup
        applicationId: "contacts-sync"
        providerId: "google"
    }
}
