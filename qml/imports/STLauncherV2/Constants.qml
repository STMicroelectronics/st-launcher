pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property bool debug_enabled: false

    readonly property int width: _windowWidth
    readonly property int height: _windowHeight

    readonly property real verticalScalingRatio: (_windowHeight / 720)
    readonly property real horizontaalScalingRatio: (_windowWidth / 1280)

    readonly property int largeIconeSize: adjustedSize(240)
    readonly property int realIconeSize: 160

    readonly property bool roundIcons: true

    property string relativeFontDirectory: "fonts"

    // This is platform's specific text content - data are read from file.
    property var info_txt: qsTr(platformdata.readDesc())
    readonly property bool is_simulator: platformdata.isSimulator()

    // This Launcher support only STM32MP15xx & STM32MP25xx products!
    readonly property var stm32mp2_chip: info_txt.indexOf("STM32MP2")

    /* Edit this comment to add your custom font */
    readonly property font font: Qt.font({
                                             family: Qt.application.font.family,
                                             pixelSize: Qt.application.font.pixelSize
                                         })
    readonly property font largeFont: Qt.font({
                                                  family: Qt.application.font.family,
                                                  pixelSize: Qt.application.font.pixelSize * 1.6
                                              })

    readonly property color backgroundColor: "#E9E9EA" // "#d6d7d9"
    readonly property color stDarkBlueColor: "#03234b"
    readonly property color stLightBlueColor: "#20A5E1"
    readonly property color stPinkColor: "#E6007E"
    readonly property color stGreyColor: "#464650"
    readonly property color stYellowColor: "#FFD200"

    function dp(px) {
        return px * Screen.devicePixelRatio;
    }

    function adjustedSize(size, hor=1) {
        if (hor)
            return Math.ceil(size * horizontaalScalingRatio);
        else
            return Math.ceil(size * verticalScalingRatio);
    }

    function msg_log(msg){
        if (debug_enabled) {
            console.log(msg);
        }
    }

    function msg_print(msg){ console.log(msg); }
}
