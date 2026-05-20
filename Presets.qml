import QtQuick
import QtQuick.Controls

Page 
{

    background: Rectangle 
    {
       color: "#2c2c2c"
    }

    Column 
    {
        anchors.centerIn: parent
        spacing: 30

        Label 
        {
            text: "Presets"
            color: "white"
            font.pixelSize: 26
        }

        Button 
        {
            text: "Back"
            onClicked: stack.pop()
        }
    }
}