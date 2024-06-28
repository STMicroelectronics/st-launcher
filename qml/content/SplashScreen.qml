import QtQuick 2.15
import QtQuick.Controls 2.15
import STLauncherV2 1.0

Item {
    id: splash_window
    width: Constants.width
    height: Constants.height

    Rectangle {
        id: backround
        anchors.fill: parent
        color: Constants.stDarkBlueColor

        Image {
            anchors.fill: parent
            source: "images/STLauncher_MPU_demo-01.png"
        }

        Item {
            id: toparea
            visible: false // Not used in this new version
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: parent.width
            height: Math.floor(parent.height / 2)

            Image {
                id: stlogo
                anchors.fill: parent
                anchors.topMargin: Constants.adjustedSize(64)
                source: "images/st_logo.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: product_name
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                color: Constants.stLightBlueColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: Constants.adjustedSize(18)
                font.letterSpacing: Constants.adjustedSize(2.0)
                font.family: "D-DIN Exp"
                text: Constants.stm32mp2_chip >= 0 ? "STM32MP25x" : "STM32MP15x"
            }
        }

        Item {
            id: bottomarea
            anchors.top: toparea.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            visible: false // Not used in this new version

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
                    leftPadding: Constants.adjustedSize(100)
                    rightPadding: Constants.adjustedSize(100)
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
                }
            }
        }
    }
}
