import QtQuick 2.15
import QtQuick.Controls 2.15

Page 
{
    id: page

    background: Rectangle 
    {
        color: "#101010"
    }

    Column 
    {
        anchors.centerIn: parent
        width: parent.width - 40
        spacing: 10

        Label 
        {
            text: "Connection"
            color: "white"
            font.pixelSize: 26
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button 
        {
            text: "Back"
            width: parent.width 

            contentItem: Text 
            {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle 
            {
                color: "#2c2c2c"
                border.color: "#444"
                radius: 6
            }

            onClicked:
            {
                stack.pop()
            }
        }

        Button
        {
            text: "Connect to ESP"
            width: parent.width 

            contentItem: Text 
            {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle 
            {
                color: "#2c2c2c"
                border.color: "#444"
                radius: 6
            }

            onClicked:
            {
                esp32.connectToESP32()
            }
        }
    }

    Popup
    {
        id: errorPopup

        width: 300
        height: 150

        anchors.centerIn: Overlay.overlay

        modal: true

        background: Rectangle
        {
            radius: 8
            color: "#2c2c2c"
            border.color: "#444" 
        }

        contentItem: Text
        {
            id: popupText

            text: ""
            color: "white"
            font.pixelSize: 16
            wrapMode: Text.WordWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Connections
    {
        target: esp32

        function onConnectionStatus(connection)
        {
            if (connection === false)
            {
                popupText.text = "No ESP32 found.\nPlease connect the device."
            }
            else
            {
                popupText.text = "ESP32 connected!"
            }

            errorPopup.open()
        }
    }
}