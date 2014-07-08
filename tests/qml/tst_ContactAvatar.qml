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
import QtContacts 5.0
import QtTest 1.0
import Ubuntu.Test 0.1
import Ubuntu.Contacts 0.1

import "ContactUtil.js" as ContactUtilJS

Item {
    id: root

    width: units.gu(40)
    height: units.gu(80)


    UbuntuTestCase {
        id: contactAvatarTestCase
        name: 'contactAvatarTestCase'

        property var avatarComponent: null

        when: windowShown

        function createContact(firstName, avatarUrl)
        {
            var details = [
               {detail: 'Name', field: 'firstName', value: firstName },
               {detail: 'Avatar', field: 'imageUrl', value: avatarUrl }
            ];

            return  ContactUtilJS.createContact(details, contactAvatarTestCase)
        }

        function init()
        {
            avatarComponent = Qt.createQmlObject('import Ubuntu.Contacts 0.1; ContactAvatar{  height: 100; width: 100; }', root);
        }

        function cleanup()
        {
            if (avatarComponent) {
                avatarComponent.destroy()
                avatarComponent = null
            }
        }

        function test_initalState()
        {
            compare(avatarComponent.displayName, avatarComponent.fallbackDisplayName)
            compare(avatarComponent.avatarUrl, avatarComponent.fallbackAvatarUrl)
            compare(avatarComponent.showAvatarPicture, true)
        }

        function test_initials_and_fallback_name()
        {
            var contactName = "Name Lastname"
            avatarComponent.fallbackDisplayName = contactName
            compare(avatarComponent.displayName, contactName)
            compare(avatarComponent.initials, "NL")

            contactName = "Fullname"
            avatarComponent.fallbackDisplayName = contactName
            compare(avatarComponent.displayName, contactName)
            compare(avatarComponent.initials, "F")

            contactName = "3212300"
            avatarComponent.fallbackDisplayName = contactName
            compare(avatarComponent.displayName, contactName)
            compare(avatarComponent.initials, "")

            contactName = "$&#@"
            avatarComponent.fallbackDisplayName = contactName
            compare(avatarComponent.displayName, contactName)
            compare(avatarComponent.initials, "")

            contactName = ""
            avatarComponent.fallbackDisplayName = contactName
            compare(avatarComponent.displayName, contactName)
            compare(avatarComponent.initials, "")
        }

        function test_show_avatar_with_fallback_name()
        {
            var fallbackName = "Name Lastname"
            avatarComponent.fallbackDisplayName = fallbackName
            compare(avatarComponent.showAvatarPicture, false)
        }

        function test_show_avatar_with_contact_and_fallback_name()
        {
            var fallbackName = "Name Lastname"
            avatarComponent.contactElement = createContact("", "")
            avatarComponent.fallbackDisplayName = fallbackName
            compare(avatarComponent.showAvatarPicture, false)
        }

        function test_show_avatar_with_named_contact()
        {
            avatarComponent.contactElement = createContact("Name Lastname", "")
            compare(avatarComponent.showAvatarPicture, false)
        }

        function test_show_avatar_with_contact_empty_name_valid_image()
        {
            avatarComponent.contactElement = createContact("", "image://theme/contact")
            compare(avatarComponent.showAvatarPicture, true)
        }

        function test_show_avatar_with_contact_with_name_and_image()
        {
            avatarComponent.contactElement = createContact("My Name", "image://theme/my_image")
            compare(avatarComponent.showAvatarPicture, true)
        }

        function test_show_avatar_with_contact_with_especial_name_and_image()
        {
            avatarComponent.contactElement = createContact("3214567", "")
            compare(avatarComponent.showAvatarPicture, true)
        }

        function test_show_avatar_after_update_contact_()
        {
            var contact = createContact("My Name", "")
            avatarComponent.contactElement = contact
            compare(avatarComponent.showAvatarPicture, false)

            var avatarDetail = contact.detail(ContactDetail.Avatar)
            avatarDetail.imageUrl = "image://theme/contact"
            avatarComponent.reload()
            compare(avatarComponent.showAvatarPicture, true)
        }

        function test_image_visibility()
        {
            waitForRendering(avatarComponent);
            var avatarInitials = findChild(avatarComponent, "avatarInitials")
            var avatarImage = findChild(avatarComponent, "avatarImage")

            avatarComponent.showAvatarPicture = true
            tryCompare(avatarInitials, "visible", false)
            tryCompare(avatarImage, "source", avatarComponent.fallbackAvatarUrl)

            avatarComponent.showAvatarPicture = false
            tryCompare(avatarImage, "source", "")
            tryCompare(avatarImage, "status", Image.Null)
            tryCompare(avatarInitials, "visible", true)
        }
    }
}
