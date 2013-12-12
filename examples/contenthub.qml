import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Content 0.1
import QtContacts 5.0
import Ubuntu.Components.ListItems 0.1 as ListItem

Rectangle {
  id: root
  height: 500
  width: 500

  ContactModel {
      id: contactModel

      manager: "memory"
  }

  ListView {
      id: contactView

      model: contactModel
      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        bottom: buttons.bottom
      }

      delegate: ListItem.Subtitled {
          text: contact.name.firstName
          subText: contact.phoneNumber.number
      }
  }

  Row {
      id: buttons
      anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
      }
      height: childrenRect.height
      Button {
          text: "Import a single contact"
           onClicked: {
               activeTransfer = ContentHub.importContent(ContentType.Contacts);
               activeTransfer.selectionType = ContentTransfer.Single;
               activeTransfer.start();
          }
      }
      Button {
          text: "Import multiple contacts"
           onClicked: {
               activeTransfer = ContentHub.importContent(ContentType.Contacts);
               activeTransfer.selectionType = ContentTransfer.Multiple;
               activeTransfer.start();
          }
      }
  }

  ContentImportHint {
      id: importHint
      anchors.fill: parent
      activeTransfer: root.activeTransfer
  }
  property var activeTransfer
  Connections {
      target: root.activeTransfer ? root.activeTransfer : null
      onStateChanged: {
          if (root.activeTransfer.state === ContentTransfer.Charged) {
              var fileName = root.activeTransfer.items[0].url
              console.debug("open vcard:" + fileName)
              contactModel.importContacts(fileName)
          }
      }
  }
}
