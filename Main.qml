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
                                anchors.centerIn: parent.top
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
                                onClicked: stack.push(Qt.resolvedUrl("Filters.qml"))

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

                    anchors.top: presetsButton.bottom
                    anchors.topMargin: 15

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

                        ListElement { name: "Filter 1" }
                        ListElement { name: "Filter 2" }
                        ListElement { name: "Filter 3" }
                        ListElement { name: "Filter 4" }
                        ListElement { name: "Filter 5" }
                    }

                    DelegateModel 
                    {
                        id: visualModel
                        model: filterModel

                        delegate: MouseArea 
                        {
                            id: dragArea

                            property int visualIndex: DelegateModel.itemsIndex

                            width: listView.width
                            height: 70

                            drag.target: content

                            Rectangle 
                            {
                                id: content

                                width: parent.width - 20
                                height: 60

                                anchors.horizontalCenter: parent.horizontalCenter

                                y: 5

                                radius: 6
                                color: "#2c2c2c"
                                border.color: "#555"

                                Drag.active: dragArea.drag.active
                                Drag.source: dragArea

                                Text 
                                {
                                    anchors.centerIn: parent
                                    text: "name"
                                    color: "white"
                                    font.pixelSize: 18
                                }
                            }

                            DropArea 
                            {
                                anchors.fill: parent

                                onEntered: function(drag) 
                                {
                                    visualModel.items.move(
                                        drag.source.visualIndex,
                                        dragArea.visualIndex
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
