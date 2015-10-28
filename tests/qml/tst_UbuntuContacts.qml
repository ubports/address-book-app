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
import QtTest 1.0
import Ubuntu.Contacts 0.1

Item {
    id: root

    TestCase {
        id: uContactsTest
        name: 'UBuntuContactTestCase'

        function test_normalize_string()
        {
            compare(Contacts.normalized("não"), "nao")
            compare(Contacts.normalized("josé"), "jose")
            compare(Contacts.normalized("açaí"), "acai")
            compare(Contacts.normalized("Роман Щекин"), "Роман Щекин")
            compare(Contacts.normalized("阿娜丝塔西"), "阿娜丝塔西")
        }

        function test_containsLetters()
        {
            compare(Contacts.containsLetters("123456"), false)
            compare(Contacts.containsLetters("(123)"), false)
            compare(Contacts.containsLetters("Щекин"), true)
            compare(Contacts.containsLetters("阿娜丝塔西"), true)
            compare(Contacts.containsLetters("阿娜23西"), true)
        }
    }
}
