/****************************************************************************
**
** Copyright (C) 2013 Canonical Ltd
**
****************************************************************************/
import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1

MainView {
    id: mainView

    width: units.gu(40)
    height: units.gu(71)

    PageStack {
        id: mainStack

        anchors.fill: parent
    }

    Component.onCompleted: mainStack.push(Qt.resolvedUrl("ContactList.qml"))
}
