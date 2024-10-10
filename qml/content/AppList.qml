import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import STLauncherV2 1.0

Item {
    id: applist_item
    signal itemSelected(variant app)

    property int itemsPerPage: root.getNumberOfColumns() * root.getNumberOfRows()
    property int page_idx: 0

    function current() { return apps.get(_list.model.index(_list.currentIndex, 0)); }
    function current_index() { return _list.currentIndex; }
    function up() { _list.moveCurrentIndexUp() }
    function down() { _list.moveCurrentIndexDown() }
    function left() { _list.moveCurrentIndexLeft() }
    function right() { _list.moveCurrentIndexRight() }
    function home() { _list.currentIndex = 0 }
    function end() { _list.currentIndex = _list.count - 1 }
    function filter(text) { apps.setFilterName(text) }
    function count() { return _list.count; }
    function toggleIgnored() { apps.toggleFilterShowIgnored() }
    function pages() { return Math.ceil(count() / itemsPerPage) }
    function current_page() { return page_idx }
    function first_page() { return _list.atXBeginning }
    function last_page() { return _list.atXEnd }
    function next_page() {
        var columns = getNumberOfColumns()
        if(!_list.moving && !debounce.running) { // (_list.currentIndex+columns) < _list.count &&
            // Calculate the selected item index in the next page to be displayed
            var index = _list.currentIndex + itemsPerPage
            if (index >= _list.count - 1) {
                Constants.msg_log("Going outside the list: ", index, "(", _list.count, ")")
                index = _list.count - itemsPerPage + 1
            }
            _list.currentIndex = index;

            _pageRightAnimation.restart();
            debounce.restart();
            page_idx+=1
            Constants.msg_log("Moving to the next page ", page_idx, "(", _list.currentIndex, ")")
        }
    }
    function previous_page() {
        var columns = getNumberOfColumns()
        if(!_list.moving && !debounce.running) { // _list.currentIndex >= columns &&
            // Calculate the selected item index in the next page to be displayed
            var index = _list.currentIndex - itemsPerPage
            if (index < 0) {
                Constants.msg_log("Going outside the list: ", index, "(", _list.count, ")")
                index = 0
            }
            _list.currentIndex = index;
            _pageLeftAnimation.restart();
            debounce.restart();
            page_idx-=1
            Constants.msg_log("Moving to the previous page ", page_idx, "(", _list.currentIndex, ")")
        } else {
            Constants.msg_log("CANT Moving to the previous page ", page_idx, "(", _list.currentIndex, ")")
        }
    }

    function add_new_element(filename) {
        Constants.msg_log("Adding a new Item to the list..", filename)
        apps.add_new(filename)
        _list.forceLayout();
    }
    function remove_element(index)  {
        Constants.msg_log("Removind Item with index ", index)
        const app = apps.get(_list.model.index(index, 0));
        if (app) {
            //Constants.msg_log("Removind Application ", app.name())
           apps.remove(_list.model.index(index, 0))
            _list.forceLayout()
        }
    }
    function execute_app(index) {
        apps.run_app(_list.model.index(_list.currentIndex, 0))
    }

    function getCellWidth() { return _list.cellWidth; }
    function getCellHeight() { return _list.cellHeight; }

    property int itemWidth: _list.cellWidth - (_list.padding * 2)
    property int itemHeight: _list.cellHeight - (_list.padding * 2)
    property int icon_size: Constants.adjustedSize(140)

    GridView {
        id: _list
        property int padding: 5
        property int currentIndexAtLeft: 0

        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        model: apps
        leftMargin: 0
        rightMargin: 0
        topMargin: 2
        bottomMargin: 2
        clip: true
        cacheBuffer: parent.height // pixels in direction of scrolling (vertical) the view used for caching
        flickableDirection: Flickable.HorizontalFlick
        boundsMovement: Flickable.StopAtBounds
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationWraps: true
        flow: Grid.TopToBottom
        interactive: pages() > 1

        cellHeight: Constants.adjustedSize(220, 0)
        cellWidth: Constants.adjustedSize(190, 1)

        //This is to recenter your grid when a swipe occurs, so the paging remains correct
        onMovementEnded: {
            var index = indexAt(contentX + 10, 1);
            var xoff = Math.round(_list.currentItem.x - contentX);
            var isFullyVisible = (xoff > _list.x && xoff + _list.currentItem.width < _list.x + _list.width)
            if (index !== -1) {
                if (!isFullyVisible) {
                    _list.currentIndex = index // This is setting cuurent selected index to the first left one
                }

                // Update the new page index
                if (_list.atXEnd) {
                    // This is the last page!
                    page_idx = pages() - 1;
                } else if (_list.atXBeginning) {
                    // The is the first page!
                    page_idx = 0;
                } else {
                    page_idx = Math.floor((index + (index % itemsPerPage) + 1) / itemsPerPage)
                }
                Constants.msg_log("Sliding to the page ", page_idx, "(", itemsPerPage, " - ", index, ")")
            } else { Constants.msg_log("Index is negatif!!!") }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { properties: "scale"; from: 1; to: 0; duration: 250; easing.type: Easing.OutQuad }
            }
        }

        add: Transition {
            enabled: applist_item.visible
            SequentialAnimation {
                NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 150; easing.type: Easing.InQuad }
            }
        }

        displaced: Transition {
            ParallelAnimation {
                NumberAnimation { properties: "scale"; from: 1; to: 0; duration: 100; easing.type: Easing.OutQuad }
                NumberAnimation { properties: "x,y"; duration: 250 }
                NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 150; easing.type: Easing.InQuad }
            }
        }

        populate: Transition {
            NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 250; easing.type: Easing.InQuad }
        }

        //These animations are used to animate the page changes
        NumberAnimation { id: _pageRightAnimation; target: _list; property: "contentX"; to: _list.contentX + _list.width; duration: 250 }
        NumberAnimation { id: _pageLeftAnimation; target: _list; property: "contentX"; to: _list.contentX - _list.width; duration: 250 }

        Component {
            id: listItem

            Column {
                property variant item: model
                objectName: "component_column"
                spacing: 2

                Item {
                    objectName: "component_item"
                    width: _list.cellWidth
                    height: _list.cellHeight

                    Image {
                        id: icon
                        source: "images/main_icon_element.svg"
                        cache: true
                        smooth: true
                        height: icon_size
                        width: icon_size
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Math.floor(icon_size / 10)
                        visible: !Constants.roundIcons

                        ColorOverlay {
                            id: overlay
                            objectName: "iconOverlay"
                            anchors.fill: icon
                            source: icon
                            color: Constants.stLightBlueColor
                            antialiasing: true
                        }

                        Image {
                            id: icon2
                            source: model.icon
                            cache: true
                            smooth: true
                            anchors.fill : parent
                            anchors.margins: Math.floor(icon_size / 5)

                            ColorOverlay {
                                anchors.fill: icon2
                                source: icon2
                                color: Constants.stDarkBlueColor
                                antialiasing: true
                            }
                        }

                        states: State {
                            name: "highlight"
                            when:index===_list.currentIndex
                            PropertyChanges {
                                target: overlay
                                color: Constants.stPinkColor
                            }
                        }
                    }

                    Rectangle {
                        id: icon_rect
                        color: Constants.stDarkBlueColor
                        height: icon_size
                        width: icon_size
                        radius: 90
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: Math.floor(icon_size / 10)
                        visible: Constants.roundIcons

                        Image {
                            id: icon2_rect
                            source: model.icon
                            cache: true
                            smooth: true
                            anchors.fill : parent
                            anchors.margins: Math.floor(icon_size / 5)

                            ColorOverlay {
                                id: overlay_rect
                                anchors.fill: icon2_rect
                                source: icon2_rect
                                color: "white"
                                antialiasing: true
                            }
                        }

                        states: State {
                            name: "highlight"
                            when:index===_list.currentIndex
                            PropertyChanges {
                                target: overlay_rect
                                color: Constants.stDarkBlueColor
                            }
                            PropertyChanges {
                                target: icon_rect
                                color: Constants.stYellowColor
                            }
                        }
                    }

                    Item  {
                        anchors.top: icon.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10

                        Label {
                            id: label
                            text: model.display
                            color: Constants.stDarkBlueColor
                            wrapMode:  Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignTop
                            fontSizeMode: Text.FixedSize
                            font.pointSize: Constants.adjustedSize(12)
                            anchors.fill: parent
                            font.family: "D-DIN Exp"
                            font.bold: false
                            font.weight: Font.ExtraBold
                        }
                    }

                    MouseArea {
                        id: mouse_area
                        anchors.fill: icon
                        propagateComposedEvents: false
                        preventStealing: true

                        onReleased: {
                            if (_list.currentIndex === index && _list.currentItem.item) {
                                Constants.msg_log("Selected Item index = " + _list.currentIndex)
                                applist_item.itemSelected(_list.currentItem.item) // Run the application
                            }
                            _list.currentIndex = index
                        }
                    }
                }
            }
        }

        delegate: listItem
    }

    //A debounce timer, so the page buttons will not get the movement out of sync
    Timer{
        id: debounce
        running: false; repeat: false; interval: 300
    }
}

