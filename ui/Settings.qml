import QtQuick
import QtQuick.Controls

Page {

    background: Rectangle {
       color: "#111"
    }

    Column {
        anchors.centerIn: parent
        spacing: 30

        Label {
            text: "Settings"
            color: "white"
            font.pixelSize: 26
        }

        Button {
            text: "Back"
            onClicked: stack.pop()
        }
    }
}