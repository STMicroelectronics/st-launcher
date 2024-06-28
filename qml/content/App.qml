import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import QtQuick.VirtualKeyboard 2.15
import QtGraphicalEffects 1.12
import STLauncherV2 1.0

Window {
    id: main_window
    width: Constants.width
    height: Constants.height

    visibility: Qt.platform.os === "linux" ? Window.FullScreen : Window.AutomaticVisibility
    flags: (Qt.FramelessWindowHint | Qt.WindowCloseButtonHint | Qt.WindowStaysOnTopHint | Qt.Window)
    color: Constants.backgroundColor
    title: qsTr("ST Application Launcher V2")
    visible: true

    property bool appsReady: false
    property bool appIsRunning: false

    onActiveChanged: {
        if (!active) {
            Constants.msg_log('Lost focus!')
            if(windowLoader.valid && appIsRunning) {
                Constants.msg_log('Selected application is now running.')
            }
        }
        if (!appIsRunning) {
            main_window.flags &= ~Qt.WindowStaysOnBottomHint
            main_window.flags |= Qt.WindowStaysOnTopHint
        } else {
            main_window.flags &= ~Qt.WindowStaysOnTopHint
            main_window.flags |= Qt.WindowStaysOnBottomHint
        }
    }

    // This function is our QML slot to C++
    function runningChanged(running) {
        Constants.msg_log("App: Running changed: " + running)
        appIsRunning = running
        // Running signal will be sent only when the process is shown on the screen!
        if(windowLoader.valid) {
            // Need to feed this information to down level to disable Click Mask
            windowLoader.item.runningChanged(appIsRunning);
        }
        if (running) {
            main_window.flags &= ~Qt.WindowStaysOnTopHint
            main_window.flags |= Qt.WindowStaysOnBottomHint
        } else {
            main_window.flags &= ~Qt.WindowStaysOnBottomHint
            main_window.flags |= Qt.WindowStaysOnTopHint
        }
    }

    function errorMessageChanged(msg) {
        // Need to feed this information to down level to disable Loading screen
        windowLoader.item.processErrorReceived(msg);
    }

    function readyChanged(ready) {
        Constants.msg_log("Ready Changed : " + (ready ? "true" : "false"))
        appsReady = ready
    }


    Rectangle {
        id: welcome
        height: Constants.height
        width: Constants.width
        color: Constants.backgroundColor
        anchors.fill: parent
        signal sendErrorMessage(string msg, int itemIndex)
        objectName: "LoaderObject"

        Component.onCompleted: { splash_timer.start() }

        Loader {
            id: windowLoader
            focus: true
            anchors.fill: parent
            source: "SplashScreen.qml"
            property bool valid: item !== null
        }

        Item {
            id: bottombar
            visible: true
            anchors.left: welcome.left
            anchors.right: welcome.right
            anchors.bottom: welcome.bottom

            height: (welcome.height / 7)

            Image {
                id: start_button
                visible: false // Not used in this new version
                //visible: appsReady
                anchors.top: parent.top
                anchors.topMargin: Constants.adjustedSize(10, 0)
                anchors.horizontalCenter: parent.horizontalCenter
                source: "images/button.svg"
                fillMode: Image.PreserveAspectFit
                width: Constants.adjustedSize(200, 1)
                height: Constants.adjustedSize(51, 0)

                ColorOverlay{
                    anchors.fill: start_button
                    source: start_button
                    color: Constants.stLightBlueColor
                    antialiasing: true
                }

                Text {
                    anchors.centerIn: parent
                    color: Constants.stDarkBlueColor
                    text: "START"
                    font.pixelSize: Constants.adjustedSize(18)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.letterSpacing: Constants.adjustedSize(2.0)
                    font.family: "D-DIN Exp"
                }
                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: false
                    hoverEnabled: true
                    preventStealing: true
                    onClicked: {
                        Constants.msg_log("Start Application Launcher")
                        start_button.visible = false
                        windowLoader.source = "AppMainMenu.qml"
                    }
                }
            }
        }

        Timer {
            id: splash_timer
            interval: 3000; running: false; repeat: false

            onTriggered: {
                windowLoader.source = "AppMainMenu.qml"
            }
        }

        Connections {
            ignoreUnknownSignals: true
            target: windowLoader.valid ? windowLoader.item : null
            function onSubMenuExit() {
                start_button.visible = true
                windowLoader.source = "AppMainMenu.qml"
            }
        }

        Connections {
            ignoreUnknownSignals: true
            target: windowLoader.valid ? windowLoader.item : null
            function onMainMenuError(msg,itemIndex) {
                Constants.msg_log(msg)
                welcome.sendErrorMessage(msg, itemIndex)
            }
        }
    }
}

