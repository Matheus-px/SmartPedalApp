import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 

pragma ComponentBehavior: Bound

ApplicationWindow 
{
    visible: true
    width: 400
    height: 700
    color: "black"

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
            background: Rectangle { color: "black" }

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
                                    radius: 4
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
                                    radius: 4
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

                    anchors.bottom: sendButton.top
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

                    DelegateModel 
                    {
                        id: visualModel
                        model: filterModel

                        delegate: Item
                        {
                            id: delegateRoot

                            required property string name
                            required property bool enable
                            property int visualIndex: DelegateModel.itemsIndex

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
                                color: mouseArea.drag.active ?
                                    "#3a3a3a" :
                                    "#2c2c2c"

                                border.color: "#555"

                                RowLayout
                                {
                                    anchors.fill: parent
                                    anchors.margins: 15

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
                                                delegateRoot.visualIndex,
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
                                MouseArea
                                {
                                    id: mouseArea

                                    anchors.fill: parent

                                    drag.target: parent
                                    drag.axis: Drag.YAxis

                                    propagateComposedEvents: true

                                    onPressed: function(mouse)
                                    {
                                        mouse.accepted = false
                                    }

                                    onReleased:
                                    {
                                        parent.y = 5
                                    }
                                }

                                Drag.active: mouseArea.drag.active
                                Drag.source: delegateRoot

                                Behavior on y
                                {
                                    NumberAnimation
                                    {
                                        duration: 120
                                    }
                                }
                            }

                            DropArea
                            {
                                anchors.fill: parent

                                onEntered: function(drag)
                                {
                                    visualModel.items.move(
                                        drag.source.visualIndex,
                                        delegateRoot.visualIndex
                                    )
                                }
                            }
                        }
                    }

                    ListView 
                    {
                        id: listView

                        anchors.fill: parent
                        anchors.margins: 10

                        spacing: 8

                        model: visualModel
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
                    }
                }

                Button 
                {
                    id: sendButton
                    text: "Send"

                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 15

                    height: 50

                    background: Rectangle 
                    {
                        color: "#2c2c2c"
                        radius: 4
                    }
                }
        }
    }
}
