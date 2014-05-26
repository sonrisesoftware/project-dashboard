import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Item {
    anchors.fill: parent

    property string title
    default property alias contents: _contents.children
    property list<Action> actions

    Rectangle {
        anchors.fill: _title
        color: Qt.rgba(0,0,0,0.1)
    }

    ListItem.Standard {
        id: _title
        text: title

        Row {
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                verticalCenter: parent.verticalCenter
            }

            spacing: units.gu(1)

            Repeater {
                model: actions
                delegate: Button {
                    id: button

                    text: modelData.text
                    onTriggered: action.triggered(button)
                }
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
