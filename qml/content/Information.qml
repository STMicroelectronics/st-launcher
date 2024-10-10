import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects
import STLauncherV2 1.0

Rectangle {
    id: information_base
    visible: false
    color: "black"
    layer.enabled: true
    anchors.fill: parent

    property string qt_desc_txt: '<b>Qt Group offers cross-platform solutions for the entire software development lifecycle.</b><br>
                                <p>Qt Group (Nasdaq Helsinki: QTCOM) is a global software company, trusted by industry leaders
                                and over 1.5 million developers worldwide to create applications and smart devices that users love.
                                We help our customers to increase productivity through the entire product development lifecycle -
                                from UI design and software development to quality management and deployment.<br>
                                <p>Our customers are in more than 70 different industries in over 180 countries. Qt Group is
                                headquartered in Espoo, Finland, and employs almost 800 people globally.'
    property string st_desc_txt: 'The STM32 family of general-purpose 32-bit microprocessors (MPUs) provides developers with greater design flexibility and performance. STM32 application processors are based on single or dual Arm Cortex®-A cores, combined with a Cortex®-M core. From cost-effective, single-core MPUs to more advanced, multicore MPUs, ST offers a scalable approach to help developers find the right fit.<br>
                                <p>The STM32MPU product family is coming with a full ecosystem including software development tools, and various embedded software as the OpenSTLinux distribution.
                                The OpenSTLinux distribution is a Linux distribution based on the OpenEmbedded build Framework, covers all the STM32MPUs, runs on the respectively Arm Cortex®-A processors.
                                This current OpenSTLinux distribution is part of the MPU Ecosystem v5.1'

    Loader {
        id: subLoader
        source: "StmInfo.qml"
        active: false
        asynchronous: true
        visible: status == Loader.Ready
        z: 2
    }

    Component.onCompleted: {
        subLoader.setSource("StmInfo.qml");
    }

    Image {
        anchors.fill: parent
        source: "images/Screen_round_corners"
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
                onReleased: { information_base.destroy() }
            }
        }

        Text {
            anchors.verticalCenter: back_bkg.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            text: "Informations"
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
    }

    Item {
        id: info_area
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: topbar.bottom
        anchors.bottom: bottombar.top

        // Discard all Touch events in background items
        MultiPointTouchArea {
            id: clickCatcher
            anchors.fill: parent
            mouseEnabled: true
            minimumTouchPoints: 0
            maximumTouchPoints: 0
        }

        RowLayout {
            id: logos
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            anchors.topMargin: Constants.adjustedSize(5)
            spacing: Constants.width / 3

            Rectangle {
                id: st_logo
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                Layout.preferredWidth: Constants.adjustedSize(220, 0)
                Layout.preferredHeight: Constants.adjustedSize(220, 1)
                Layout.leftMargin: Constants.adjustedSize(200, 0)
                color: "white"
                radius: 16

                Image {
                    anchors.fill : parent
                    source: "images/ST_logo_2020_blue_V_rgb.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 0
                    MouseArea {
                        id: mouseSTM
                        enabled: false // Not yet reviewed
                        anchors.fill: parent
                        propagateComposedEvents: false
                        hoverEnabled: true
                        preventStealing: true
                        onClicked: {
                            subLoader.setSource("StmInfo.qml");
                            subLoader.active = true
                        }
                    }
                }

                Text {
                    id: st_txt
                    anchors { top: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    anchors.topMargin: Constants.adjustedSize(12)
                    text: Constants.stm32mp2_chip >= 0 ? "STM32 MP2" : "STM32 MP1"
                    font.letterSpacing: Constants.adjustedSize(2.5)
                    font.pixelSize: Constants.adjustedSize(20)
                    font.capitalization : Font.AllUppercase
                    maximumLineCount: 1
                    font.bold: true
                    font.weight: Font.ExtraBold
                    font.family: "D-DIN Exp"
                    color: Constants.stDarkBlueColor
                }

                Text {
                    anchors { top: st_txt.bottom; horizontalCenter: st_txt.horizontalCenter }
                    anchors.topMargin: Constants.adjustedSize(14)
                    wrapMode: Text.WordWrap
                    width: Constants.adjustedSize(600, 1)
                    horizontalAlignment: Text.AlignJustify
                    Layout.fillWidth: true
                    text: qsTr(st_desc_txt)
                    font.letterSpacing: Constants.adjustedSize(1)
                    font.pixelSize: Constants.adjustedSize(14)
                    maximumLineCount: 50
                    fontSizeMode: Text.VerticalFit; style: Text.Raised; styleColor: "#AAAAAA"; minimumPixelSize: 8
                    font.bold: false
                    font.weight: Font.ExtraBold
                    font.family: "D-DIN Exp"
                    color: Constants.stDarkBlueColor
                }
            }

            Rectangle {
                id: qt_logo
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: Constants.adjustedSize(220, 0)
                Layout.preferredHeight: Constants.adjustedSize(220, 1)
                Layout.rightMargin: Constants.adjustedSize(200, 0)
                color: "white"
                radius: 16

                Image {
                    anchors.fill : parent
                    source: "images/Qt_logo_black.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.margins: 30
                }

                Text {
                    id: qt_txt
                    anchors { top: parent.bottom; horizontalCenter: parent.horizontalCenter }
                    anchors.topMargin: Constants.adjustedSize(12)
                    text: "Qt Framework"
                    font.letterSpacing: Constants.adjustedSize(2.5)
                    font.pixelSize: Constants.adjustedSize(20)
                    font.capitalization : Font.AllUppercase
                    maximumLineCount: 1
                    font.bold: true
                    font.weight: Font.ExtraBold
                    font.family: "D-DIN Exp"
                    color: Constants.stDarkBlueColor
                }

                Text {
                    anchors { top: qt_txt.bottom; horizontalCenter: qt_txt.horizontalCenter }
                    anchors.topMargin: Constants.adjustedSize(14)
                    text: qsTr(qt_desc_txt)
                    textFormat: Text.StyledText
                    wrapMode: Text.WordWrap
                    width: Constants.adjustedSize(600, 1)
                    horizontalAlignment: Text.AlignJustify
                    Layout.fillWidth: true
                    font.letterSpacing: Constants.adjustedSize(1)
                    font.pixelSize: Constants.adjustedSize(15)
                    maximumLineCount: 50
                    fontSizeMode: Text.VerticalFit; style: Text.Raised; styleColor: "#AAAAAA"; minimumPixelSize: 8
                    font.bold: false
                    font.weight: Font.ExtraBold
                    font.family: "D-DIN Exp"
                    color: Constants.stDarkBlueColor
                }
            }
        }
    }

    Item {
        id: bottombar
        visible: true
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: Constants.adjustedSize(70, 1)

        Text {
            id: text1
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            anchors.topMargin: Constants.adjustedSize(5)
            text: "Want to know more? Visit us here:"
            font.letterSpacing: Constants.adjustedSize(2.0)
            font.pixelSize: Constants.adjustedSize(22)
            maximumLineCount: 1
            font.bold: true
            font.weight: Font.Bold
            font.family: "D-DIN Exp"
            color: Constants.stDarkBlueColor
        }

        Text {
            anchors { bottom: bottombar.bottom; left: bottombar.left }
            anchors.bottomMargin: Constants.adjustedSize(8)
            anchors.leftMargin: Constants.adjustedSize(180)
            text: '<font color="blue">http://www.st.com</font>' // "<a href=\"http://www.st.com\">http://www.st.com</a>"
            font.letterSpacing: Constants.adjustedSize(3.0)
            font.pixelSize: Constants.adjustedSize(22)
            maximumLineCount: 1
            font.bold: false
            font.weight: Font.Bold
            font.family: "D-DIN Exp"
            color: Constants.stDarkBlueColor
        }

        Text {
            anchors { bottom: bottombar.bottom; right: bottombar.right }
            anchors.bottomMargin: Constants.adjustedSize(8)
            anchors.rightMargin: Constants.adjustedSize(180)
            text: '<font color="blue">https://www.qt.io</font>' //"<a href=\"https://www.qt.io\">https://www.qt.io</a>"
            font.letterSpacing: Constants.adjustedSize(3.0)
            font.pixelSize: Constants.adjustedSize(22)
            maximumLineCount: 1
            font.bold: false
            font.weight: Font.Bold
            font.family: "D-DIN Exp"
            color: Constants.stDarkBlueColor
        }
    }
}
