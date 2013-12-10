import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Content 0.1


Rectangle {
  id: root
  height: 500
  width: 500
  Row {
      id: buttons
      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
      }
      Button {
          text: "Import from default"
           onClicked: {
               var peer = ContentHub.defaultSourceForType(ContentType.Contacts);
               activeTransfer = ContentHub.importContent(ContentType.Contact, peer);
          }
      }
      Button {
          text: "Import from a selectable list"
           onClicked: {
               activeTransfer = ContentHub.importContent(ContentType.Contacts);
               activeTransfer.selectionType = ContentTransfer.Multiple;
               activeTransfer.start();
          }
      }
  }
  TextArea {
    id: textArea
    anchors {
        left: parent.left
        right: parent.right
        top: buttons.bottom
        bottom: parent.bottom
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
              var fileName = root.activeTransfer.items[0]
              fh = fopen(fileName, 0)
              if(fh!=-1) {
                length = flength(fh)
                var str = fread(fh, length)
                fclose(fh)
                console.debug("VCARD FILE: " + str)
                textArea.text = str
              } else {
                console.debug("Fail to open file:" + fileName)
                textArea.text = "Fail to open file:" + fileName
              }
          }
      }
  }
}
