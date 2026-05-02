import QtQuick 2.0
import SddmComponents 2.0
//
Rectangle {
    id: container
    anchors.fill: parent
    color: "black"

    property bool showInput: false

    focus: true

    Keys.onPressed: {
        showInput = true
        realInput.forceActiveFocus()
    }

    // ─── Background ───────────────────────────────────────────────
    Image {
        anchors.fill: parent
        source: config.background || "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // ─── Full-screen click zone ───────────────────────────────────
    MouseArea {
        anchors.fill: parent
        z: 1
        onClicked: {
            if (!showInput) {
                showInput = true
                realInput.forceActiveFocus()
            } else {
                showInput = false
                realInput.text = ""
                error_message.text = ""
                container.focus = true
            }
        }
    }

    // ─── Clock (centered, blinking colon) ─────────────────────────
    Column {
        id: clockColumn
        anchors.centerIn: parent
        spacing: 6
        z: 2

        property date dateTime: new Date()
        property bool colonVisible: true

        Timer {
            interval: 1200
            running: true
            repeat: true
            onTriggered: {
                clockColumn.dateTime = new Date()
                clockColumn.colonVisible = !clockColumn.colonVisible
            }
        }

        // Time row: HH : MM with blinking colon
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Text {
                text: Qt.formatTime(clockColumn.dateTime, "hh")
                font.pixelSize: 56
                font.family: "FOT-Rodin Pro DB"
                color: "white"
            }

            Text {
                text: ":"
                font.pixelSize: 56
                font.family: "FOT-Rodin Pro DB"
                color: "white"
                opacity: clockColumn.colonVisible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            Text {
                text: Qt.formatTime(clockColumn.dateTime, "mm")
                font.pixelSize: 56
                font.family: "FOT-Rodin Pro DB"
                color: "white"
            }
        }

        Text {
            text: Qt.formatDate(clockColumn.dateTime, "dddd, dd MMMM yyyy")
            font.pixelSize: 16
            font.family: "FOT-Rodin Pro M"
            color: "#cccccc"
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // ─── Hidden TextInput (captures keystrokes) ───────────────────
    TextInput {
        id: realInput
        width: 1; height: 1; opacity: 0
        echoMode: TextInput.Password
        z: 3

        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                sddm.login(userModel.lastUser, realInput.text, session.index)
            }
            if (event.key === Qt.Key_Escape) {
                showInput = false
                realInput.text = ""
                error_message.text = ""
                container.focus = true
            }
        }
    }

    // ─── Password UI block ────────────────────────────────────────
    Rectangle {
        id: inputWrapper
        z: 3
        color: "transparent"
        visible: opacity > 0
        opacity: showInput ? 1.0 : 0.0
        width: 260
        height: inputColumn.height + 20
        anchors.top: clockColumn.bottom
        anchors.topMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        transform: Translate {
            y: showInput ? 0 : 8
            Behavior on y {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: realInput.forceActiveFocus()
        }

        Column {
            id: inputColumn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            spacing: 10

            Text {
                text: "Password"
                color: "#cccccc"
                font.pixelSize: 13
                font.family: "FOT-Rodin Pro M"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Animated dots
            Item {
                width: Math.max(dotsRow.width, 10)
                height: 14
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    id: dotsRow
                    anchors.centerIn: parent
                    spacing: 7

                    Repeater {
                        model: realInput.text.length
                        delegate: Rectangle {
                            id: dot
                            width: 7; height: 7; radius: 3.5
                            color: "white"
                            opacity: 0; scale: 0.3

                            Component.onCompleted: popIn.start()

                            ParallelAnimation {
                                id: popIn
                                NumberAnimation {
                                    target: dot; property: "opacity"
                                    to: 1; duration: 100
                                    easing.type: Easing.OutQuad
                                }
                                NumberAnimation {
                                    target: dot; property: "scale"
                                    to: 1; duration: 200
                                    easing.type: Easing.OutBack
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 220; height: 1
                color: "#55ffffff"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: error_message
                text: ""
                color: "#ff5555"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ─── Top bar ──────────────────────────────────────────────────
    Item {
        width: parent.width
        height: 48
        anchors.top: parent.top
        z: 5

        ComboBox {
            id: session
            visible: false
            model: sessionModel
            index: sessionModel.lastIndex
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            // Reboot button
            Rectangle {
                width: 28; height: 28
                radius: 14
                color: rebootHover.containsMouse ? "#22ffffff" : "transparent"
                border.color: rebootHover.containsMouse ? "#99ffffff" : "#55ffffff"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Image {
                    anchors.centerIn: parent
                    source: "components/resources/reboot.png"
                    width: 12; height: 12
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    id: rebootHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.reboot()
                }
            }

            // Shutdown button
            Rectangle {
                width: 28; height: 28
                radius: 14
                color: shutdownHover.containsMouse ? "#22ff4444" : "transparent"
                border.color: shutdownHover.containsMouse ? "#99ff4444" : "#55ff4444"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }

                Image {
                    anchors.centerIn: parent
                    source: "components/resources/shutdown.png"
                    width: 12; height: 12
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                MouseArea {
                    id: shutdownHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.powerOff()
                }
            }
        }
    }

    // ─── Login feedback ───────────────────────────────────────────
    Connections {
        target: sddm
        function onLoginFailed() {
            error_message.text = "Incorrect password"
            realInput.text = ""
            realInput.forceActiveFocus()
        }
    }
}
