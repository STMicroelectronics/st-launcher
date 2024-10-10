import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import STLauncherV2 1.0

Rectangle {
    id: setting_win
    color: "black"
    layer.enabled: true
    anchors.fill: parent

    property int icon_size: Constants.adjustedSize(300)

    Image {
        anchors.fill: parent
        source: "images/Screen_round_corners.svg"
    }

    Item {
        id: topbar
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: parent.height / 5

        Rectangle {
            id: about_btn_bkg
            visible: false // TODO: enable information pannel
            radius: 16
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: height / 2
            anchors.rightMargin: height / 2
            antialiasing: true
            color: Constants.stDarkBlueColor
            width: Constants.adjustedSize(80, 1)
            height: Constants.adjustedSize(80, 1)

            RoundButton {
                id: about_btn
                visible: true
                radius: parent.radius - 4
                anchors.fill: parent
                flat: true
                display: AbstractButton.IconOnly
                icon.source: "images/icon_small_help.svg"
                icon.width: Constants.adjustedSize(24, 1)
                icon.height: Constants.adjustedSize(43, 0)
                icon.color: Constants.stLightBlueColor
                onClicked: {  } // Does nothing!
                onReleased: {
                    // We could use Loader but the dynamic component creation would be saving more memory but running slowly
                    // TODO : check performances & memory usage : Loader vs Dynamic Components creation
                    var component = Qt.createComponent("About.qml")
                    if (component.status === Component.Ready) {
                        var window = component.createObject(setting_win)
                        if (window === null) {
                            console.log("Error creating object");
                        } else {
                            Qt.platform.os === "linux" ? window.showFullScreen() : window.raise(); // show up the screen
                            Constants.msg_log("About Screen Object created!")
                        }
                    } else {
                        console.error("Cant create About Window!")
                    }
                }
            }
        }

        Rectangle {
            id: back_bkg
            visible: true
            radius: 16
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: height / 2
            anchors.leftMargin: height / 2
            antialiasing: true
            color: Constants.stDarkBlueColor
            width: Constants.adjustedSize(80, 1)
            height: Constants.adjustedSize(80, 1)

            RoundButton {
                id: back_btn
                visible: true
                radius: parent.radius - 4
                anchors.fill: parent
                flat: true
                display: AbstractButton.IconOnly
                icon.source: "images/icone_close_window.svg"
                icon.width: Constants.adjustedSize(30, 1)
                icon.height: Constants.adjustedSize(30, 0)
                icon.color: "#ffffff"
                onReleased: { setting_win.destroy() }
            }
        }

        Text {
            anchors.verticalCenter: about_btn_bkg.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            text: "SETTINGS"
            font.pixelSize: Constants.adjustedSize(42)
            font.letterSpacing: Constants.adjustedSize(2.2)
            color: Constants.stDarkBlueColor
            font.bold: false
            renderType: Text.NativeRendering
            font.weight: Font.ExtraBold
            style: Text.Raised
            font.preferShaping: false
        }
    }

    Item {
        id: buttons_area
        width: Constants.adjustedSize(460 * 2, 1)
        height: Constants.adjustedSize(436, 0)
        anchors.centerIn: parent

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

        Item {
            id: item_exit
            width: Constants.adjustedSize(460, 1)
            height: Constants.adjustedSize(436, 0)
            anchors.right: parent.right


            Image {
                id: exit_icon
                source: "images/main_icon_element.svg"
                cache: true
                smooth: true
                height: icon_size
                width: icon_size
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Constants.adjustedSize(72)

                ColorOverlay {
                    id: overlay
                    anchors.fill: exit_icon
                    source: exit_icon
                    color: Constants.stDarkBlueColor
                    antialiasing: true
                }

                Image {
                    id: exit_icon2
                    source: "images/icon_small_exit.png"
                    cache: true
                    smooth: true
                    anchors.fill : parent
                    anchors.margins: Math.floor(icon_size / 4)

                    ColorOverlay {
                        anchors.fill: exit_icon2
                        source: exit_icon2
                        color: "white"
                        antialiasing: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: false
                    hoverEnabled: true
                    preventStealing: true
                    onClicked: {
                        Constants.msg_log("Exit Launcher")
                        Qt.callLater(Qt.quit)
                    }
                }
            }

            Item  {
                anchors.top: exit_icon.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Constants.adjustedSize(18)

                Label {
                    id: exit_label
                    text: "EXIT"
                    color: Constants.stDarkBlueColor
                    wrapMode:  Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    fontSizeMode: Text.FixedSize
                    font.pointSize: Constants.adjustedSize(26)
                    font.letterSpacing: Constants.adjustedSize(2.2)
                    anchors.fill: parent
                    font.family: "D-DIN Exp"
                    font.bold: false
                    renderType: Text.NativeRendering
                    font.weight: Font.ExtraBold
                    style: Text.Raised
                    font.preferShaping: false
                }
            }
        }

        Item {
            id: item_about
            width: Constants.adjustedSize(460, 1)
            height: Constants.adjustedSize(436, 0)
            anchors.left: parent.left

            Image {
                id: about_icon
                source: "images/main_icon_element.svg"
                cache: true
                smooth: true
                height: icon_size
                width: icon_size
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Constants.adjustedSize(72)

                ColorOverlay {
                    //id: overlay
                    anchors.fill: about_icon
                    source: about_icon
                    color: Constants.stDarkBlueColor
                    antialiasing: true
                }

                Image {
                    id: about_icon2
                    source: "images/icon_small_informations.png"
                    cache: true
                    smooth: true
                    anchors.fill : parent
                    anchors.margins: Math.floor(icon_size / 4)

                    ColorOverlay {
                        anchors.fill: about_icon2
                        source: about_icon2
                        color: "white"
                        antialiasing: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: false
                    hoverEnabled: true
                    preventStealing: true
                    onClicked: {
                        Constants.msg_log("Go to Information Screen")
                        // We could use Loader but the dynamic component creation would be saving more memory but running slowly
                        // TODO : check performances & memory usage : Loader vs Dynamic Components creation
                        var component = Qt.createComponent("Information.qml")
                        if (component.status === Component.Ready) {
                            var window = component.createObject(setting_win)
                            //Qt.platform.os === "linux" ? window.showFullScreen() : window.show(); // show up the screen
                            window.visible = true
                        } else {
                            console.error("Cant create Setting Window!")
                        }
                    }
                }
            }

            Item  {
                anchors.top: about_icon.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Constants.adjustedSize(18)

                Label {
                    id: about_label
                    text: "INFORMATIONS"
                    color: Constants.stDarkBlueColor
                    wrapMode:  Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignTop
                    fontSizeMode: Text.FixedSize
                    font.pointSize: Constants.adjustedSize(26)
                    font.letterSpacing: Constants.adjustedSize(2.2)
                    anchors.fill: parent
                    font.family: "D-DIN Exp"
                    font.bold: false
                    renderType: Text.NativeRendering
                    font.weight: Font.ExtraBold
                    style: Text.Raised
                    font.preferShaping: false
                }
            }
        }
    }
}
