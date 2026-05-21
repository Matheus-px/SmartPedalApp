import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 

pragma ComponentBehavior: Bound

ApplicationWindow 
{
    visible: true
    width: 400
    height: 700
    color: 'black'

    StackView 
    {
        id: stack
        anchors.fill: parent
    }

    Component.onCompleted: 
    {
        stack.push(mainPageComponent)
    }

    Component 
    {
        id: mainPageComponent

        Page 
        {
            background: Rectangle { color: "#101010" }

            Column 
            {
                anchors.fill: parent
                spacing: 0

                Rectangle 
                {
                    width: parent.width
                    height: 64
                    color: "#2c2c2c"

                    RowLayout 
                    {
                        anchors.fill: parent

                        Item { width: 48 }
                        Item { Layout.fillWidth: true }

                        Label 
                        {
                            text: "Smart Pedal Settings"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle 
                        {
                            width: 48
                            height: parent.height
                            color: "#2c2c2c"
                            

                            ToolButton 
                            {
                                anchors.centerIn: parent
                                text: "CFG" // PRECISA POR ICON DPS
                                onClicked: stack.push(Qt.resolvedUrl("Settings.qml"))
                            }
                        }
                    }
                }
                    Column 
                    {
                        anchors.top: parent.top
                        anchors.topMargin: 80
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 15
                        spacing: 20

                        Column 
                        {
                            width: parent.width
                            spacing: 8

                            ToolButton 
                            {
                                text: "Connection"
                                width: parent.width
                                onClicked: stack.push(Qt.resolvedUrl("Connection.qml"))

                                background: Rectangle 
                                {
                                    color: "#2c2c2c"
                                    border.color: "#444"
                                    radius: 6
                                }
                            }

                            ToolButton 
                            {
                                id: presetsButton
                                text: "Presets"
                                width: parent.width
                                onClicked: stack.push(Qt.resolvedUrl("Presets.qml"))

                                background: Rectangle 
                                {
                                    color: "#2c2c2c"
                                    border.color: "#444"
                                    radius: 6
                                }
                            }
                        }

                        // Button {
                        //    text: "View"
                        //}
                    }
                }

                /* Bottom rectangle filling remaining space
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 350
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: "#2c2c2c"
                    border.color: "#444"
                }
                */
                Rectangle 
                {
                    id: filterArea

                    anchors.top: parent.top
                    anchors.topMargin: 170

                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.bottom: bottomBar.top
                    anchors.bottomMargin: 15

                    anchors.margins: 15

                    color: "#1a1a1a"
                    border.color: "#444"
                    radius: 6

                    ListModel 
                    {
                        id: filterModel

                        ListElement
                        {
                            name: "Filter 1"
                            enable: true
                        }

                        ListElement
                        {
                            name: "Filter 2"
                            enable: true
                        }

                        ListElement
                        {
                            name: "Filter 3"
                            enable: false
                        }

                        ListElement
                        {
                            name: "Filter 4"
                            enable: true
                        }

                        ListElement
                        {
                            name: "Filter 5"
                            enable: false
                        }
                    }

                    ListView 
                    {
                        id: listView

                        anchors.fill: parent
                        anchors.margins: 10

                        spacing: 8

                        model: filterModel
                        move: Transition 
                        {
                            NumberAnimation 
                            {
                                properties: "x,y"
                                duration: 150
                            }
                        }

                        displaced: Transition 
                        {
                            NumberAnimation 
                            {
                                properties: "x,y"
                                duration: 150
                            }
                        }
                        delegate: Item
                        {
                            id: delegateRoot

                            required property string name
                            required property bool enable
                            required property int index

                            width: listView.width
                            height: 70

                            Rectangle
                            {
                                id: content

                                width: parent.width - 20
                                height: 60

                                anchors.horizontalCenter:
                                    parent.horizontalCenter

                                y: 5

                                radius: 6

                                color:
                                    dragHandle.drag.active ?
                                    "#3a3a3a" :
                                    "#2c2c2c"

                                border.color: "#555"

                                Behavior on y
                                {
                                    NumberAnimation
                                    {
                                        duration: 120
                                    }
                                }

                                RowLayout
                                {
                                    anchors.fill: parent
                                    anchors.margins: 15
                                    spacing: 10

                                    Rectangle
                                    {
                                        width: 32
                                        height: 32
                                        radius: 4

                                        color: "#444"

                                        Layout.alignment: Qt.AlignVCenter

                                        Text
                                        {
                                            anchors.centerIn: parent
                                            text: "≡"
                                            color: "white"
                                            font.pixelSize: 18
                                        }

                                        MouseArea
                                        {
                                            id: dragHandle

                                            anchors.fill: parent

                                            drag.target: content
                                            drag.axis: Drag.YAxis

                                            onReleased:
                                            {
                                                content.y = 5
                                            }
                                        }
                                    }

                                    Text
                                    {
                                        text: delegateRoot.name

                                        color: "white"
                                        font.pixelSize: 18

                                        Layout.fillWidth: true
                                    }

                                    Button
                                    {
                                        text:
                                            delegateRoot.enable ?
                                            "ON" :
                                            "OFF"

                                        onClicked:
                                        {
                                            filterModel.setProperty(
                                                delegateRoot.index,
                                                "enable",
                                                !delegateRoot.enable
                                            )
                                        }

                                        background: Rectangle
                                        {
                                            radius: 4

                                            color:
                                                delegateRoot.enable ?
                                                "#00bfa5" :
                                                "#444"
                                        }
                                    }
                                }

                                Drag.active: dragHandle.drag.active
                                Drag.source: delegateRoot
                            }

                            DropArea
                            {
                                anchors.fill: parent

                                onEntered: function(drag)
                                {
                                    filterModel.move(
                                        drag.source.index,
                                        delegateRoot.index,
                                        1
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
                    id: sendButton
                    anchors.centerIn: parent

                    width: parent.width - 30
                    height: 50

                    contentItem: Text
                    {
                        text: "Send"
                        color: "black"
                        font.pixelSize: 16

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle
                    {
                        radius: 6
                        color: "#00bfa5"
                        border.color : "#444"
                    }
                }
            }
        }
    }
}
