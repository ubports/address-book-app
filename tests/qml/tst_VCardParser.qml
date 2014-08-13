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
import QtTest 1.0
import Ubuntu.Test 0.1
import QtContacts 5.0

Item {
    id: root

    width: units.gu(40)
    height: units.gu(80)

    property var vcardParserComponent
    property var spy

    UbuntuTestCase {
        id: vcardParser
        name: 'vcardParserTestCase'

        function init()
        {
            vcardParserComponent = Qt.createQmlObject('import Ubuntu.Contacts 0.1; VCardParser{ }', root);
            spy = Qt.createQmlObject('import QtTest 1.0; SignalSpy{ }', root);
            spy.target = vcardParserComponent
            spy.signalName = "vcardParsed"
        }

        function cleanup()
        {
            if (vcardParserComponent) {
                vcardParserComponent.destroy()
                vcardParserComponent = null
            }
            if (spy) {
                spy.destroy()
                spy = null
            }
        }

        function test_import_file()
        {
            vcardParserComponent.vCardUrl = Qt.resolvedUrl("../data/vcard.vcf")
            tryCompare(spy, "count", 1)
            compare(spy.signalArguments[0][0], ContactModel.ImportNoError)
            compare(vcardParserComponent.contacts.length, 3)
        }
    }
}
