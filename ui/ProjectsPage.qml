import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../backend"
import "../ubuntu-ui-extras"

Page {
    id: page
    
    title: i18n.tr("Projects")

    actions: [
        Action {
            id: newProjectAction
            text: i18n.tr("New Project")
            iconSource: getIcon("add")
            onTriggered: PopupUtils.open(newProjectDialog, page)
        }

    ]

    ListView {
        id: projectsList
        anchors.fill: parent
        model: backend.projects
        delegate: ListItem.Standard {
            text: project.name
            onClicked: pageStack.push(Qt.resolvedUrl("ProjectPage.qml"), {docId: modelData})

            Project {
                id: project
                docId: modelData
            }
        }
    }

    Label {
        anchors.centerIn: parent
        visible: projectsList.count === 0
        opacity: 0.5
        fontSize: "large"
        text: i18n.tr("No projects")
    }

    Scrollbar {
        flickableItem: projectsList
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        ToolbarButton {
            action: newProjectAction
        }
    }

    Component {
        id: newProjectDialog

        InputDialog {
            title: i18n.tr("Create New Project")
            text: i18n.tr("Please enter a name for your new project.")
            placeholderText: i18n.tr("Name")
            onAccepted: backend.newProject(value)
        }
    }
}
