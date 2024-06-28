import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQuick.VirtualKeyboard 2.15
import STLauncherV2 1.0

Rectangle {
    id: root
    objectName: "mainWindow"
    width: Constants.width
    height: Constants.height
    color: "black"

    signal changeToAppWindow
    signal stopLoadingScreen
    signal stopLoadingScreenWithError(string msg)
    signal mainMenuError(string msg, int itemIndex)

    property QtObject loading_screen: null
    property bool loader_error_received: false
    property string loader_error_msg: "Error! Can't Run Application"

    function getNumberOfRows() { return Math.floor(list_pannel.height / applist.getCellHeight()); }
    function getNumberOfColumns() { return Math.floor(list_pannel.width / applist.getCellWidth()); } // Only displayed columns
    function getTotalNumberOfColumns() { return Math.ceil(applist.count() / getNumberOfRows()); } // All columns including ones not on screen
    function show_search_button() {
        if (search_input.inputActive())
            return true;
        return  (getNumberOfRows() * applist.getCellHeight()) > list_pannel.height ? true : false;
    }

    // This function is our QML slot to C++
    function readyChanged(ready) {
        applist.home();
        applist.visible = true
    }

    function runningChanged(running) {
        Constants.msg_log("Running Changed : "+ (running ? "true" : "false"));
        if (running) {
            wait_timer.stop();
            stopLoadingScreen(); // should stop busy_timer!
        } else {
            click_mask.enabled = false;
        }
    }

    function processErrorReceived(msg) {
        Constants.msg_log(msg + " ERROR RECEIVED");
        loader_error_msg = msg
        loader_error_received = true
    }

    function executeApp(input) {
        if (!click_mask.enabled) {
            click_mask.enabled = true
            wait_timer.start()
            applist.execute_app(input)
        }
    }

    Image {
        anchors.fill: parent
        source: "images/Screen_round_corners.svg"
    }

    Item {
        id: bottombar
        visible: true
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: root.bottom

        height: (root.height / 7)

        Item {
            id: next_btn_bkg
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: Constants.adjustedSize(width / 2)
            anchors.topMargin: Constants.adjustedSize(3, 0)
            antialiasing: true
            width: Constants.adjustedSize(80, 1)
            height: Constants.adjustedSize(80, 0)

            RoundButton {
                id: next_btn
                visible: !applist.last_page()
                radius: parent.radius
                anchors.fill: parent
                flat: true
                display: AbstractButton.IconOnly
                icon.source: "images/icon_small_arrow_next.svg"
                icon.width: Constants.adjustedSize(24, 1)
                icon.height: Constants.adjustedSize(42, 0)
                background: Rectangle {
                         anchors.fill: parent
                         radius: Constants.roundIcons
                         opacity: enabled ? 1 : 0.3
                         color: next_btn.down ? "#d0d0d0" : "transparent"
                }
                onReleased: {
                    // move to next applications list column
                    applist.next_page();
                }
            }
        }

        Item {
            id: back_btn_bkg
            visible: !applist.first_page()
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: Constants.adjustedSize(width / 2)
            anchors.topMargin: Constants.adjustedSize(3, 0)
            antialiasing: true
            width: Constants.adjustedSize(80, 1)
            height: Constants.adjustedSize(80, 0)

            RoundButton {
                id: back_btn
                visible: true
                radius: parent.radius
                anchors.fill: parent
                flat: true
                display: AbstractButton.IconOnly
                icon.source: "images/icon_small_arrow_back.svg"
                icon.width: Constants.adjustedSize(24, 1)
                icon.height: Constants.adjustedSize(42, 0)
                background: Rectangle {
                         anchors.fill: parent
                         radius: Constants.roundIcons
                         opacity: enabled ? 1 : 0.3
                         color: back_btn.down ? "#d0d0d0" : "transparent"
                }
                onReleased: {
                    // move to previous applications list column
                    applist.previous_page();
                }
            }
        }

        Image {
            id: add_new_btn
            visible: false // TODO: implement this!
            anchors.top: parent.top
            anchors.topMargin: Constants.adjustedSize(10, 0)
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/button.svg"
            fillMode: Image.PreserveAspectFit
            width: Constants.adjustedSize(200, 1)
            height: Constants.adjustedSize(51, 0)

            Text {
                anchors.centerIn: parent
                color: "#ffffff"
                text: "ADD NEW"
                font.pixelSize: Constants.adjustedSize(22)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.weight: Font.Bold
                font.family: "D-DIN Exp"
            }
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
                hoverEnabled: true
                preventStealing: true
                onClicked: {
                    applist.add_new_element("blabla/blabla/blabla.zip");
                }
            }
        }
    }

    Item {
        id: topbar
        visible: true
        anchors.left: root.left
        anchors.right: root.right
        anchors.top: root.top

        height: root.height / 5

        Rectangle {
            id: setting_btn_bkg
            visible: true
            radius: 16
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: height / 2
            anchors.rightMargin: height / 2
            antialiasing: true
            color:  Constants.stDarkBlueColor
            width: Constants.adjustedSize(80, 1)
            height: Constants.adjustedSize(80, 1)

            RoundButton {
                id: setting_btn
                visible: true
                radius: parent.radius - 4
                anchors.fill: parent
                flat: true
                display: AbstractButton.IconOnly
                icon.source: "images/icon_small_settings.svg"
                icon.width: Constants.adjustedSize(48, 1)
                icon.height: Constants.adjustedSize(48, 0)
                icon.color: "#ffffff"
                onClicked: {  } // Does nothing!
                onReleased: {
                    // We could use Loader but the dynamic component creation would be saving more memory but running slowly
                    // TODO : check performances & memory usage : Loader vs Dynamic Components creation
                    var component = Qt.createComponent("Setting.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(root)
                        if (window === null) {
                            console.log("Error creating object");
                        }
                    } else {
                        console.error("Cant create Setting Window!")
                    }
                }
            }
        }

        // Search input area // To be used for now!
        CommandInput {
            id: search_input
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: setting_btn_bkg.anchors.topMargin
            anchors.leftMargin: setting_btn_bkg.anchors.rightMargin
            Layout.alignment: Qt.AlignLeft | Qt.AlignHCenter
            onSelected: executeApp(text)
            onMoveUp: applist.up()
            onMoveDown: applist.down()
            onMoveLeft: applist.left()
            onMoveRight: applist.right()
            onMoveHome: applist.home()
            onMoveEnd: applist.end()
            onSearchChanged: applist.filter(text)
            onToggleIgnored: applist.toggleIgnored()
            visible: true // show_search_button()
            width: Constants.adjustedSize(parent.width / 3, 1)
            height: Constants.adjustedSize(setting_btn_bkg.height, 0)
        }

        Text {
            id: testClock
            anchors.verticalCenter: setting_btn_bkg.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter

            font.pixelSize: Constants.adjustedSize(42)
            font.letterSpacing: Constants.adjustedSize(1.5)

            maximumLineCount: 1
            font.bold: true
            font.weight: Font.ExtraBold
            font.family: "D-DIN Exp"
            color: Constants.stDarkBlueColor
            function updateTime()
            {
                testClock.text = Qt.formatDateTime(new Date(), "hh:mm")
            }
        }

        Timer {
            id: textTimer
            interval: 1000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: {
                testClock.updateTime();
            }
        }
    }

    Item {
        id: list_pannel
        anchors.left: root.left
        anchors.right: root.right
        anchors.bottom: bottombar.top
        anchors.top: topbar.bottom
        anchors.leftMargin:  Constants.adjustedSize(70)
        anchors.rightMargin: list_pannel.anchors.leftMargin

        RowLayout {
            id: gird_apps
            anchors.fill: list_pannel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 0

            AppList {
                id: applist
                visible: true
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                onItemSelected: root.executeApp(current_index())
                Rectangle {
                    id: list_area
                    visible: false // used to debug positionning of icons in the list
                    opacity: 0.5
                    radius: 8
                    anchors.fill: parent
                    color: "transparent"
                    antialiasing: true
                    border.color: "#3775fc"
                    border.width: 1
                }
            }
        }

        PageIndicator {
            id: pageIndicator
            count: applist.pages()
            currentIndex: applist.current_page()
            interactive: true
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter


            delegate: Rectangle {
                    implicitWidth: Constants.adjustedSize(15)
                    implicitHeight: Constants.adjustedSize(15)

                    radius: width
                    color: Constants.stDarkBlueColor

                    opacity: index === applist.current_page() ? 0.95 : pressed ? 0.7 : 0.45

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 100
                        }
                    }
                }
        }

        MouseArea {
            id: click_mask
            anchors.fill: parent
            propagateComposedEvents: false
            hoverEnabled: true
            preventStealing: true
            enabled: false
            onClicked: {
                Constants.msg_log("Mask Clicked");
            }
        }
    }

    // Virtual Keyboard
    // To be used when the number of applications is so big
    // For small number of installed application an App Filter
    // by categories will be used instead.
    InputPanel {
        id: inputPanel
        visible: false
        anchors.leftMargin: parent.width/10
        anchors.rightMargin: parent.width/10
        anchors.left: parent.left
        anchors.right: parent.right
        z:1000

        property bool showKeyboard : active
        y: showKeyboard ? parent.height - height : parent.height

        Behavior on y {
            SequentialAnimation {
                PropertyAction { target: inputPanel; property: "visible"; value: true }
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
                PropertyAction { target: inputPanel; property: "visible"; value: active } // actually change the controlled property between the 2 other animations
            }
        }
    }

    Timer {
        id: wait_timer
        interval: 100; running: false; repeat: false

        onTriggered: {
            if (loading_screen == null) {
                var component = Qt.createComponent("LoadingScreen.qml")
                if (component.status === Component.Ready) {
                    loading_screen = component.createObject(main_window, {error: loader_error_received, error_msg: loader_error_msg})
                    if (loading_screen == null) {
                        console.log("Error creating object");
                    } else {
                        loading_screen.show()
                        Constants.msg_log("Custom Busy Indicator created!")
                    }
                } else {
                    console.error("Cant create Information Window!")
                }
            } else {
                console.error("Loading screen already created!")
            }
        }
    }

    Connections {
        ignoreUnknownSignals: true
        target: loading_screen ? loading_screen : null
        function onLoadingAppError() {
            Constants.msg_log("Destroying Loading Screen")
            loading_screen.destroy()
            loading_screen = null
            click_mask.enabled = false
        }
    }
}
