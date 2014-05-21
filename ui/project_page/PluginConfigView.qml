import QtQuick 2.0
import Ubuntu.Components 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem

PageView {

    title: plugin.title

    default property alias contents: _contents.children

    Rectangle {
        anchors.fill: _title
        color: Qt.rgba(0,0,0,0.1)
    }

    ListItem.Standard {
        id: _title

        Label {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: units.gu(2)
            }
            fontSize: "large"
            text: title
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }

            spacing: units.gu(1)

            Button {
                text: "Remove"
                color: colors["red"]
            }
        }
    }

    Item {
        id: _contents

        anchors {
            left: parent.left
            right: parent.right
            top: _title.bottom
            bottom: parent.bottom
        }
    }
}
