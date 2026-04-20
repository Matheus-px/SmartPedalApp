import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 

ApplicationWindow {
    visible: true
    width: 400
    height: 700
    color: "black"

    StackView {
        id: stack
        anchors.fill: parent
    }

    Component.onCompleted: {
        stack.push(mainPageComponent)
    }

    Component {
        id: mainPageComponent

        Page {
            background: Rectangle { color: "black" }

            Column {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    width: parent.width
                    height: 64
                    color: "#2c2c2c"

                    RowLayout {
                        anchors.fill: parent

                        Item { width: 48 }
                        Item { Layout.fillWidth: true }

                        Label {
                            text: "Smart Pedal Settings"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            width: 48
                            height: parent.height
                            color: "#2c2c2c"

                            ToolButton {
                                anchors.centerIn: parent.top
                                text: "CFG" // PRECISA POR ICON DPS
                                onClicked: stack.push(Qt.resolvedUrl("Settings.qml"))
                            }

                        }
                    
                    }
                }
                    Column {
                        anchors.top: parent.top
                        anchors.topMargin: 80
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 15
                        spacing: 20

                        Column {
                            width: parent.width
                            spacing: 8

                            ToolButton {
                                text: "Connection"
                                width: parent.width
                                onClicked: stack.push(Qt.resolvedUrl("Connection.qml"))

                                background: Rectangle {
                                    color: "#2c2c2c"
                                    radius: 4
                                }
                            }

                            ToolButton {
                                text: "Filters"
                                width: parent.width
                                onClicked: stack.push(Qt.resolvedUrl("Filters.qml"))

                                background: Rectangle {
                                    color: "#2c2c2c"
                                    radius: 4
                                }
                            }
                        }

                        Button {
                            text: "View"
                        }
                    }
                }

                // Bottom rectangle filling remaining space
                Rectangle {
                    anchors.top: parent.top
                    anchors.topMargin: 160
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    color: "#2c2c2c"
                    border.color: "#444"
                }
            }
        }
    }
