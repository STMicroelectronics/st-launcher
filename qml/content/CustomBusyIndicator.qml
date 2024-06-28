import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import STLauncherV2 1.0

BusyIndicator {
    id: busy
    property int bLines: 11
    property real bLength: 10 // % of the width of the control
    property real bWidth: 5 // % of the height of the control
    property real bRadius: 13 // % of the width of the control
    property real bCorner: 1 // between 0 and 1
    property real bSpeed: 100 // smaller is faster
    property real bTrail: 0.6 // between 0 and 1
    property bool bClockWise: true

    property real bOpacity: 0.7
    property string bColor: "dimgrey"
    property string bHighlightColor: "gainsboro"
    property string bBgColor: "transparent"

    visible: true
    running: true

    implicitWidth: parent.height / 2
    implicitHeight: parent.height / 2
    anchors.centerIn: parent
    enabled: false

    style: CustomBusyIndicatorStyle {
        lines: busy.bLines
        length: busy.bLength
        width: busy.bWidth
        radius: busy.bRadius
        corner: busy.bCorner
        speed: busy.bSpeed
        trail: busy.bTrail
        clockWise: busy.bClockWise
        opacity: busy.bOpacity
        color: busy.bColor
        highlightColor: busy.bHighlightColor
        bgColor: busy.bBgColor
    }

    Text {
        id: txt_loading
        text: "Loading..."
        color: "dimgrey"
        font.pointSize: Constants.adjustedSize(18)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height / 4
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

