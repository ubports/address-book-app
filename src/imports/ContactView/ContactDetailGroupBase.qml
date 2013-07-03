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
import Ubuntu.Components.ListItems 0.1 as ListItem

FocusScope {
    id: root

    readonly property variant details : priv.details

    property string detailQmlTypeName: null
    property QtObject contact: null
    property int detailType: 0
    property bool editable: false
    property bool valid: false
    property alias title: header.text
    property alias spacing: contents.spacing
    property Component view
    property Component editor

    implicitHeight: priv.editing || root.details.length > 0 ? contents.height + units.gu(1) : 0
    visible: implicitHeight > 0

    QtObject {
        id: priv

        property variant details : contact && detailType ? contact.details(detailType) : []
        property int newDetailsCount: 0
        property bool editing: false
    }

    Connections {
        target: root.contact
        onContactChanged: {
            if (contact && detailType) {
                priv.details = contact.details(detailType)
            } else {
                priv.details = []
            }
        }
    }

    function edit() {
        if (!priv.editing) {
            priv.editing = true
            for(var i = 0; i < contents.children.length; ++i) {
                var field = contents.children[i]
                if (field.edit) {
                    field.edit()
                }
            }
        }
    }

    function save() {
        if (priv.editing) {
            for(var i = 0; i < detailFields.children.length; ++i) {
                var field = detailFields.children[i]
                if (field.save) {
                    field.save()
                }
            }
            priv.editing = false
        }
    }

    function newDetail() {
        if (detailQmlTypeName) {
            var newDetail = Qt.createQmlObject("import QtContacts 5.0; " + detailQmlTypeName + "{}", parent)
            if (newDetail) {
                root.contact.addDetail(newDetail)
                priv.newDetailsCount += 1
            }
        }
    }

    Column {
        id: contents

        anchors {
            left: parent.left
            right: parent.right
        }

        height: childrenRect.height
        Item {
            id: headerLine

            anchors {
                left: parent.left
                right: parent.right
            }
            height: units.gu(3)

            Label {
                id: header
                anchors {
                    left: parent.left
                    top: parent.top
                    right: newFieldButton.left
                    bottom: parent.bottom
                }
            }
            AbstractButton {
                id: newFieldButton

                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: units.gu(1)
                    bottom: parent.bottom
                }
                width: units.gu(2)
                height: units.gu(2)
                visible: priv.editing

                Image {
                    anchors.fill: parent
                    source: "artwork:/add-detail.png"
                    fillMode: Image.PreserveAspectFit
                }

                onClicked: root.newDetail()
            }
        }

        Repeater {
            id: detailFields

            model: root.details.length
            ContactDetailItem {
                state: priv.editing ? "edit" : "view"
                contact: root.contact
                detail: root.details[index]
                editable: root.editable
                valid: root.valid
                view: root.view
                editor: root.editor
                width: parent ? parent.width : 0
                height: implicitHeight
            }
        }
    }

    ListItem.ThinDivider {
        anchors.bottom: parent.bottom
    }
}
