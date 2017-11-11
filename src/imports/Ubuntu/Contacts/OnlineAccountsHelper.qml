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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.OnlineAccounts 0.1
import Ubuntu.OnlineAccounts.Client 0.1

Item {
    id: root

    property bool running: false
    property alias applicationId: setup.applicationId
    property var providerModel: providers
    signal finished()

    function setupExec(provider)
    {
        if (!root.running) {
            root.running = true
            setup.providerId = provider
            setup.exec()
        }
    }
    Setup {
        id: setup
        applicationId: "address-book-app"
        onFinished: {
            root.running = false
            root.finished()
        }
    }

    ProviderModel {
        id: providers
        applicationId: "address-book-app"
    }
}
