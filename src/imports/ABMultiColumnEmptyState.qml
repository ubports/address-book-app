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


Page {
    id: root

    property string headerTitle: i18n.tr("No contacts")

    header: PageHeader {
        title: root.headerTitle
    }

    ABEmptyState {
        id: emptyStateScreen

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: units.gu(6)
            rightMargin: units.gu(6)
        }
        height: childrenRect.height
        text: i18n.tr("Create a new contact by swiping up from the bottom of the screen.")
    }

    Loader {
        id: bottomEdgeLoader

        active: (pageStack.columns > 1)
        asynchronous: true
        sourceComponent: ABNewContactBottomEdge {
            id: bottomEdge

            parent: root
            height: root.height
            modelToEdit: root.pageStack.contactListPage.contactModel
            hint.flickable: root.flickable
            pageStack: root.pageStack
        }
    }

    Binding {
        target: pageStack
        property: 'bottomEdge'
        value: bottomEdgeLoader.item
        when: bottomEdgeLoader.status === Loader.Ready
    }

    Connections {
        target: pageStack
        onColumnsChanged: {
            if (pageStack.columns === 1) {
                pageStack.removePages(root)
            }
        }
    }
}
