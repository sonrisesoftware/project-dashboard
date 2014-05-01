import QtQuick 2.0
import "../qml-air"

// Widget based on code from Clock app
Rectangle {
    id: swipeBackgroundItem

    property string text

    anchors.fill: parent
    anchors.bottomMargin: units.dp(2)
    //color: Theme.palette.normal.base;
    color: willRemove ? colors["green"] : Qt.rgba(0.2,0.2,0.2,0.3)
    property color fontColor: Theme.palette.normal.baseText//Theme.palette.selected.backgroundText

    property bool willRemove: false

    Behavior on color {
        ColorAnimation { duration: UbuntuAnimation.FastDuration }
    }

    AwesomeIcon {
        id: leftSwipeDeleteIcon

        anchors {
            top: leftSwipeBackgroundText.top
            right: leftSwipeBackgroundText.left
            rightMargin: units.gu(1)
            bottom: leftSwipeBackgroundText.bottom
        }
        name: "check"
        width: height
        size: units.gu(3)
        visible: swipeBackgroundItem.state === "SwipingRight"
    }

    Label {
        id: leftSwipeBackgroundText
        visible: swipeBackgroundItem.state === "SwipingRight"
        text: swipeBackgroundItem.text
        color: fontColor

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: units.gu(2)
        }

        fontSize: "large"
    }


    AwesomeIcon {
        id: rightSwipeDeleteIcon
        name: "check"
        size: units.gu(3)

        anchors {
            top: rightSwipeBackgroundText.top
            left: rightSwipeBackgroundText.right
            leftMargin: units.gu(1)
            bottom: rightSwipeBackgroundText.bottom
        }
        width: height
        visible: swipeBackgroundItem.state === "SwipingLeft"
    }

    Label {
        id: rightSwipeBackgroundText
        visible: swipeBackgroundItem.state === "SwipingLeft"
        text: swipeBackgroundItem.text
        color: fontColor

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
        }

        fontSize: "large"
    }
}
