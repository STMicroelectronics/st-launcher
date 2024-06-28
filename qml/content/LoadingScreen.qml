import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import STLauncherV2 1.0

Window {
    id: loading_anim
    modality: Qt.ApplicationModal
    flags:  Qt.Window | Qt.FramelessWindowHint | Qt.WA_TranslucentBackground | Qt.NoDropShadowWindowHint | Qt.WindowStaysOnTopHint
    transientParent: main_window
    color: "transparent"
    width: parent.width
    height: parent.height

    signal qmlErrorSignal(msg: string)
    signal loadingAppError
    property QtObject busy_indicator: null
    property bool error: false
    property string error_msg: "Error! Can't Run Application"

    function close_loading_window() {
        Constants.msg_log("Closing Loading Window...")
        busy_timer.stop()
        popup.close()
        loading_anim.close()
    }

    Component.onCompleted: {
        if(!error) {
            busy_timer.start()
        } else {
            Constants.msg_log(error_msg)
            popup.error_text = error_msg
            popup.open()
        }
    }

    Component.onDestruction: Constants.msg_log("Nested Destruction Beginning!")

    Timer {
        id: busy_timer
        interval: 5000; running: false; repeat: false

        onTriggered: {
            busy_indicator.running = false;
            busy_indicator.enabled = false;
            busy_indicator.visible = false
            popup.open()
        }
    }

    Item {
        anchors.fill: parent
        rotation: _force_landscape_ui ? 270 : 0

        CustomBusyIndicator {
            id: busy_indicator
            width: parent.height / 2
            height: parent.height / 2
            anchors.centerIn: parent
            running: loading_anim.active
        }

        Dialog {
            id: popup
            parent: Overlay.overlay
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            width: parent.width / 3
            height: parent.height / 4
            title: "Error"
            focus: true
            modal: true
            standardButtons: Dialog.Abort
            closePolicy: Popup.CloseOnEscape
            property alias error_text: messageText.text

            Label {
                id: messageText
                text: "Failed to start selected application!"
                color: "red"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Constants.adjustedSize(18)
                verticalAlignment: Text.AlignVCenter

                anchors.fill: parent
            }

            onRejected: {
                root.mainMenuError(error_msg, applist.current_index())
                loading_anim.qmlErrorSignal(error_msg)
                loadingAppError()
                close_loading_window()
            }
        }
    }

    Connections {
        ignoreUnknownSignals: true
        target: loading_anim ? loading_anim : null
        function onStopLoadingScreen() {
            close_loading_window()
        }
        function onStopLoadingScreenWithError(msg) {
            Constants.msg_log(msg)
            root.mainMenuError(msg, applist.current_index())
            loading_anim.qmlErrorSignal(error_msg)
            loadingAppError()
            close_loading_window()
        }
    }
}


