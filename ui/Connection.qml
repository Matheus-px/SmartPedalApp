import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    id: page

    background: Rectangle {
       color: "#2c2c2c"
    }

    Column {
        anchors.centerIn: parent
        spacing: 30

        Label {
            text: "Connection"
            color: "white"
            font.pixelSize: 26
        }

        Button {
            text: "Back"
            onClicked: stack.pop()
        }
        Button{
            text: "Connect to ESP"
            onClicked:{
                esp32.connectToESP32();
            }
        }
    }
}