/*
 * Copyright (C) 2015 Canonical, Ltd.
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
import MeeGo.QOfono 0.2
import Ubuntu.Telephony.PhoneNumber 0.1


ListModel {
    id: root

    function reloadNumbers()
    {
        root.clear()

        for (var i = 0; i < simManagerList.count; i++) {
            var item = simManagerList.itemAt(i)
            if (item) {
                var numbers = item.subscriberNumbers
                for (var n in numbers) {
                    root.append({'phoneNumber': PhoneUtils.format(numbers[n]),
                                 'network': item.networkName })
                }
            }
        }
    }

    property var priv: Item {
        OfonoManager {
            id: ofonoManager
        }

        Repeater {
            id: simManagerList

            model: ofonoManager.modems
            delegate: Item {
                property alias subscriberNumbers: simManager.subscriberNumbers
                property alias networkName: networkRegistration.name

                OfonoSimManager {
                    id: simManager
                    modemPath: modelData
                    onSubscriberNumbersChanged: {
                        console.debug("New numbers:" + subscriberNumbers)
                        dirtyModel.restart()
                    }
                }

                OfonoNetworkRegistration {
                    id: networkRegistration
                    modemPath: modelData
                    onNameChanged: {
                        dirtyModel.restart()
                    }
                }
            }
            onCountChanged: dirtyModel.restart()
        }

        Timer {
            id: dirtyModel

            interval: 1000
            repeat: false
            onTriggered: root.reloadNumbers()
        }
    }
}
