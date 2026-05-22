import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

pragma ComponentBehavior: Bound

Page
{
    id: presetsPage

    background: Rectangle
    {
        color: "#101010"
    }

    Rectangle
    {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        height: 64
        color: "#2c2c2c"

        RowLayout
        {
            anchors.fill: parent
            anchors.margins: 10

            ToolButton
            {
                text: "<"

                background: Rectangle
                {
                    color: "#00bfa5"
                    radius: 6
                }

                onClicked:
                {
                    stack.pop()
                }
            }

            Label
            {
                text: "Presets"
                color: "white"
                font.pixelSize: 20
                font.bold: true

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            ToolButton
            {
                text: "+"

                background: Rectangle
                {
                    color: "#00bfa5"
                    radius: 6
                }
            }
        }
    }

    Rectangle
    {
        id: presetsArea

        anchors.top: header.bottom
        anchors.bottom: bottomBar.top

        anchors.left: parent.left
        anchors.right: parent.right

        anchors.margins: 15

        color: "#1a1a1a"

        radius: 8
        border.color: "#444"

        ListModel
        {
            id: presetsModel

            ListElement
            {
                presetName: "F1"
            }

            ListElement
            {
                presetName: "F2"
            }

            ListElement
            {
                presetName: "F3"
            }

            ListElement
            {
                presetName: "F4"
            }

            ListElement
            {
                presetName: "F5"
            }
        }

        ListView
        {
            id: presetsList

            anchors.fill: parent
            anchors.margins: 10

            spacing: 10

            model: presetsModel

            delegate: Rectangle
            {
                width: presetsList.width
                height: 70

                radius: 6

                color: "#2c2c2c"
                border.color: "#555"

                RowLayout
                {
                    anchors.fill: parent
                    anchors.margins: 15

                    Column
                    {
                        Layout.fillWidth: true

                        Text
                        {
                            text: presetName

                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }

                        Text
                        {
                            text: "Tap to load preset"

                            color: "#aaaaaa"
                            font.pixelSize: 12
                        }
                    }

                    ToolButton
                    {
                        text: "✎" // TROCAR POR ICONES
                    }

                    ToolButton
                    {
                        text: "🗑"
                    }
                }

                MouseArea
                {
                    anchors.fill: parent

                    onClicked:
                    {
                        console.log(
                            "Load preset:",
                            presetName
                        )
                    }
                }
            }
        }
    }

    Rectangle
    {
        id: bottomBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 80
        color: "#2c2c2c"

        Button
        {
            anchors.centerIn: parent

            width: parent.width - 30
            height: 50

            text: "Save Current Preset"

            background: Rectangle
            {
                radius: 6
                color: "#00bfa5"
            }
        }
    }
}