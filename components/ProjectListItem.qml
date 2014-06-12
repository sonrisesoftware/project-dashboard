import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

import "../ubuntu-ui-extras"
import "../model"

SubtitledListItem {
    id: projectDelegate
    text: project.name
    onClicked: pageStack.push(Qt.resolvedUrl("../ui/project_page/ProjectPage.qml"), {project: project})

    property Project project

    removable: true
    confirmRemoval: true

    showDivider: y + height < parent.height

    property int count: project.inbox.count

    backgroundIndicator: ListItemBackground {
        state: swipingState
        iconSource: getIcon("delete-white")
        text: "Delete"
    }

    // TODO: Nasty hack to improve the appearance of the confirm removal dialog
    Component.onCompleted: {
        var image = findChild(projectDelegate, "confirmRemovalDialog").children[0].children[0]
        image.source = ""

        var label = findChild(projectDelegate, "confirmRemovalDialog").children[0].children[1]
        label.text = ""
    }

    onItemRemoved: {
        project.remove()
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
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
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
