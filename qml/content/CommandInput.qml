import QtQuick 2.15
import QtQuick.Controls 2.15
import STLauncherV2 1.0

Item {
    id: commandInput
    implicitHeight: st_search_btn.height
    implicitWidth: parent.width

    width: parent.width
    height: st_search_btn.height

    signal selected(string text)
    signal searchChanged(string text)
    signal moveUp()
    signal moveDown()
    signal moveLeft()
    signal moveRight()
    signal moveHome()
    signal moveEnd()
    signal toggleIgnored()

    property string placeholderText: qsTr("DEMO SEARCH")
    readonly property int initial_width: {implicitWidth/3}

    function inputActive() { return (commandInputChild.width == st_search_btn.width) ? false : true }

    function debounce(text) {
        timer.payload = { text: text};
        if (timer.running) return;
        timer.start();
    }

    function doSearch(text) {
        searchChanged(text);
    }

    Timer {
        property var payload: []
        id: timer
        interval: 200
        onTriggered: { doSearch(payload.text); }
    }

    Item {
        id: commandInputChild
        width: st_search_btn.width; height: st_search_btn.height
        anchors.left: parent.left


        state: "reduced" // Start with reduced widget

        onStateChanged: {
            if (state === "reduced")
                width = st_search_btn.width
            else
                width = initial_width
        }

        Behavior on width {
            id: width_anim
            enabled: true

            NumberAnimation {
                duration: 600
                easing.type: Easing.OutQuad
            }
        }

        states: [
            State {
                name: "expended"

                PropertyChanges {
                    target: commandInputChild
                    width: initial_width
                }
            },
            State {
                name: "reduced"

                PropertyChanges {
                    target: commandInputChild
                    width: st_search_btn.width
                }
            }
        ]

        Rectangle {
            id: rect
            color: "transparent"
            antialiasing: true
            radius: 16
            anchors.fill: parent
            border.color: Constants.stDarkBlueColor
            border.width: 2
        }


        TextInput {
            id: input
            focus: false
            anchors.fill: rect
            anchors.leftMargin: st_search_btn.width
            anchors.rightMargin: 3
            verticalAlignment: "AlignVCenter"
            padding: 20
            color: "black"
            autoScroll: true
            clip: true
            font.pixelSize: input.height / 3
            font.letterSpacing: 1
            font.bold: true
            font.weight: Font.ExtraBold
            font.family: "D-DIN Exp"

            onTextEdited: debounce(input.text)
            onAccepted: selected(input.text)
            Keys.onPressed: {
                if (event.key === Qt.Key_Escape) Qt.quit();
                if (event.key === Qt.Key_Left) { event.accepted = true; moveLeft(); }
                if (event.key === Qt.Key_Right) { event.accepted = true; moveRight() }
                if (event.key === Qt.Key_Down) { event.accepted = true; moveDown(); }
                if (event.key === Qt.Key_Up) { event.accepted = true; moveUp();}
                if (event.key === Qt.Key_Home) moveHome();
                if (event.key === Qt.Key_End) moveEnd();
                if (event.key === Qt.Key_Control) { toggleIgnored(); }
            }

            Text {
                width: parent.width - 5
                height: parent.height - 5
                id: placeholder
                color: Constants.stGreyColor
                visible: !input.text
                text: placeholderText
                font.pixelSize: placeholder.height / 3
                minimumPointSize: 8
                anchors.centerIn: parent
                padding: input.padding
                verticalAlignment: "AlignVCenter"
                fontSizeMode: Text.Fit;
                elide: Text.ElideMiddle
            }
        }

        Rectangle {
            id: st_search_bkg
            radius: 16
            anchors.top: parent.top
            anchors.left: parent.left
            antialiasing: true
            color: Constants.stDarkBlueColor
            width: Constants.adjustedSize(80, 1)
            height: Constants.adjustedSize(80, 0)

            RoundButton {
                id: st_search_btn
                width: implicitWidth
                height: implicitHeight
                flat: true
                radius: parent.radius - 4
                anchors.fill: parent
                display: AbstractButton.IconOnly
                icon.source: "images/icon_small_filter.svg"
                icon.color: "white"
                icon.width: Constants.adjustedSize(50, 1)
                icon.height: Constants.adjustedSize(50, 0)
                onPressed: {
                    width_anim.enabled = true
                    if (commandInputChild.state === "reduced")
                        commandInputChild.state = "expended"
                    else
                        commandInputChild.state = "reduced"
                }
                onReleased: {
                    input.text = "" // Clear searched input
                    debounce(input.text) // Reset filter
                    width_anim.enabled = false
                }
            }
        }

    }
}
