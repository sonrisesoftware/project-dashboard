import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

ListItem.Standard {
    id: sidebarItem

    width: parent.width
    height: width

    property bool selected: false

    property int anchor: Qt.BottomEdge

    property string text
    property string iconName
    property int count

    property bool mouseOver: false

    Rectangle {
        anchors {
            fill:parent
            topMargin: anchor === Qt.BottomEdge ? -1 : 0
            bottomMargin: anchor === Qt.TopEdge ? -1 : 0
        }

        color: selected ? "#202020" : mouseOver ? "#2a2a2a" : "#333"
        opacity: selected || mouseOver ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom

            topMargin: anchor === Qt.BottomEdge ? -1 : 0
            bottomMargin: anchor === Qt.TopEdge ? -1 : 0

            leftMargin: selected ? 0 : -width

            Behavior on leftMargin {
                UbuntuNumberAnimation {}
            }
        }

        width: units.dp(4)

        color: UbuntuColors.orange
    }

    Column {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
        }

        AwesomeIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: sidebarItem.iconName
            size: label.visible ? parent.width - units.gu(4) : parent.width - units.gu(3)
            shadow: true
        }

        Label {
            id: label
            text: sidebarItem.text
            visible: sidebarItem.width >= units.gu(7.5)
            font.pixelSize: units.gu(1.6)
            anchors.horizontalCenter: parent.horizontalCenter
            style: Text.Raised
            styleColor: Qt.rgba(0,0,0,0.7)
        }
    }

    Rectangle {
        width: parent.width
        anchors.bottom: anchor == Qt.BottomEdge ? parent.bottom : undefined
        anchors.top: anchor == Qt.TopEdge ? parent.top : undefined
        height: 2
        color: Qt.rgba(0,0,0,0.7)
    }

    Rectangle {
        width: parent.width
        anchors.bottom: anchor == Qt.BottomEdge ? parent.bottom : undefined
        anchors.top: anchor == Qt.TopEdge ? parent.top : undefined
        anchors.topMargin: 1
        height: 1
        color: Qt.rgba(0.5,0.5,0.5,0.5)
    }

    Rectangle {
        width: count < 10 ? units.gu(2.5) : countLabel.width + units.gu(1.2)
        height: units.gu(2.5)
        radius: width
        opacity: count === 0 ? 0 : 1

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        anchors {
            right: parent.right
            top: parent.top
            margins: units.gu(1)
        }

        color: colors["red"]//"#d9534f"
        border.color: Qt.darker(color, 1.5)

        Label {
            id: countLabel
            color: "white"
            anchors.centerIn: parent
            text: count
        }
    }
}
