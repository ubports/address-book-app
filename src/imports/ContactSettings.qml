  /****************************************************************************
  **
  ** Copyright (C) 2013 Canonical Ltd
  **
  ****************************************************************************/
import QtQuick 2.0
import QtContacts 5.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: sortPage

    property variant model: null
    onModelChanged: {
        if (model) {
            titleSelector.selectedIndex = titleSelector.values.indexOf(model.titleField)
            subtitleSelector.selectedIndex = subtitleSelector.values.indexOf(model.subTitleField)
        }
    }

    Column {
        anchors.fill:  parent
        ListItem.ValueSelector {
            id: sortSelector

            text: "Sort by"
            values: ["First name",
                "Middle name",
                "Last name",
                "Full name",
                "Nickname",
                "Phone",
                "e-mail"]
        }

        ListItem.ValueSelector {
            id: titleSelector

            text: "Title"
            values: ["First name",
                 "Middle name",
                 "Last name",
                 "Full name",
                 "Nickname",
                 "Phone",
                 "e-mail",
                 "First name,Last name"]
        }

        ListItem.ValueSelector {
            id: subtitleSelector

            text: "Sub title"
            values: ["First name",
                 "Middle name",
                 "Last name",
                 "Full name",
                 "Nickname",
                 "Phone",
                 "e-mail",
                 "First name,Last name"]
        }
    }

    tools: ToolbarActions {
        Action {
            text: i18n.tr("Save")
            iconSource: "artwork:/edit.png"
            onTriggered: {
                model.titleField = titleSelector.values[titleSelector.selectedIndex]
                model.subTitleField = subtitleSelector.values[subtitleSelector.selectedIndex]
                model.sortOrderField = getFieldFromName(sortSelector.values[sortSelector.selectedIndex])
                pageStack.pop()
            }
        }
    }

    function getFieldFromName(fieldName) {
        if (fieldName === "First name") {
            return Name.FirstName
        } else if (fieldName === "Middle name") {
            return Name.MiddleName
        } else if (fieldName === "Last name") {
            return Name.LastName
        } else if (fieldName === "Full name") {
            return DisplayLabel.Label
        } else if (fieldName === "Nickname") {
            return Nickname.Nickname
        } else if (fieldName === "Phone") {
            return PhoneNumber.Number
        } else if (fieldName === "e-mail") {
            return Email.EmailAddress
        } else {
            return Name.FirstName
        }
    }
}
