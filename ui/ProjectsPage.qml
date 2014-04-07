/*
 * Project Dashboard - Manage everything about your projects in one app
 * Copyright (C) 2014 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../backend"
import "../ubuntu-ui-extras"

Page {
    id: page
    
    title: i18n.tr("Projects")
    objectName: "projectsPage"

    // Needs custom property to show up in autopilot tests
    property bool test: true

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
        delegate: ListItem.SingleValue {
            id: projectDelegate
            text: project.name
            value: project.inbox.count > 0 ? project.inbox.count : ""
            onClicked: pageStack.push(Qt.resolvedUrl("ProjectPage.qml"), {project: project})

            property Project project: modelData

            removable: true
            confirmRemoval: true

            backgroundIndicator: ListItemBackground {
                state: swipingState
                iconSource: getIcon("delete-white")
                text: "Delete"
            }

            // TODO: Nasty hack to improve the appearnce of the confirm removal dialog
            Component.onCompleted: {
                var image = findChild(projectDelegate, "confirmRemovalDialog").children[0].children[0]
                image.source = ""

                var label = findChild(projectDelegate, "confirmRemovalDialog").children[0].children[1]
                label.text = ""
            }

            onItemRemoved: {
                project.remove()
            }

            function findChild(obj,objectName) {
                var childs = new Array(0);
                childs.push(obj)
                while (childs.length > 0) {
                    if (childs[0].objectName == objectName) {
                        return childs[0]
                    }
                    for (var i in childs[0].data) {
                        childs.push(childs[0].data[i])
                    }
                    childs.splice(0, 1);
                }
                return null;
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
            objectName: "createProject"
            action: newProjectAction
            width: units.gu(8)
        }

        ToolbarButton {
            action: settingsAction
        }
    }

    Component {
        id: newProjectDialog

        InputDialog {
            title: i18n.tr("Create New Project")
            text: i18n.tr("Please enter a name for your new project.")
            placeholderText: i18n.tr("Name")
            onAccepted: {
                var project = backend.newProject(value)
                pageStack.push(Qt.resolvedUrl("ProjectPage.qml"), {project: project})
                notification.show(i18n.tr("Project created"))
            }
        }
    }
}
