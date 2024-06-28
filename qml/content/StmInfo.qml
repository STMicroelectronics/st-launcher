import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import STLauncherV2 1.0

Item {
    id: stm_info
    width: Constants.width
    height: Constants.height

    Image {
        anchors.fill: parent
        source: "images/Screen_round_corners"
        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: false
            hoverEnabled: true
            preventStealing: true
        }
    }

    Item {
        id: topbar
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: parent.height / 6

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
                onReleased: {
                    subLoader.setSource("");
                    subLoader.active = false
                }
            }
        }

        Text {
            anchors.verticalCenter: back_bkg.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            text: Constants.stm32mp2_chip >= 0 ? "STM32MP2 Series" : "STM32MP1 Series"
            font.capitalization : Font.SmallCaps
            font.pixelSize: Constants.adjustedSize(42)
            font.letterSpacing: Constants.adjustedSize(2.2)
            color: Constants.stDarkBlueColor
            font.bold: false
            renderType: Text.NativeRendering
            font.weight: Font.ExtraBold
            style: Text.Raised
            font.preferShaping: false
        }

        Image {
            anchors.verticalCenter: back_bkg.verticalCenter
            anchors.right: parent.right
            anchors.topMargin: height / 4
            anchors.rightMargin: height / 4
            source: "images/STM_chips.png"
            width: Constants.adjustedSize(120, 1)
            height: Constants.adjustedSize(120, 1)
            fillMode: Image.PreserveAspectFit
        }
    }

    Item {
        id: bottomarea
        anchors.top: topbar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Flickable {
            id: txflick
            anchors.fill: parent
            anchors.margins: Constants.adjustedSize(20)
            flickableDirection: Flickable.VerticalFlick
            interactive: false

            TextArea.flickable: TextArea {
                id: txarea

                topPadding: Constants.adjustedSize(10)
                bottomPadding: Constants.adjustedSize(10)
                leftPadding: Constants.adjustedSize(10)
                rightPadding: Constants.adjustedSize(10)
                readOnly: true
                text: Constants.info_txt
                textFormat: Text.AutoText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignTop
                wrapMode:  Text.WrapAtWordBoundaryOrAnywhere
                antialiasing: true

                font.bold: false
                font.pixelSize: Constants.adjustedSize(14)
                font.letterSpacing: Constants.adjustedSize(1.0)
                font.family: "D-DIN Exp"
                color: "red"

                background: Rectangle {
                    id: bound_rect
                    visible: true
                    opacity: 0.5; color: "transparent"; radius: 8;
                    border.width: 1; border.color: "#3775fc"
                }
            }
        }

        Timer {
            id: text_scrolling_tim
            running: stm_info.visible && (txarea.contentHeight > bottomarea.height)
            interval: 5000 // will be updated to 50 ms after first start
            repeat: true
            triggeredOnStart: false
            property int iteration: 0

            onTriggered: {
                if (!triggeredOnStart) {
                    triggeredOnStart = true
                    interval = 50
                } else {
                    if (txflick.contentY > txflick.contentHeight)
                        txflick.contentY = -(bound_rect.height)
                    else
                        txflick.contentY++
                }
            }
        }
    }
}
