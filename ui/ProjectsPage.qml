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
import "../components"

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
        },

        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconSource: inboxPage.count > 0 ? getIcon("bell") : getIcon("bell-o")
            onTriggered: pageStack.push(inboxPage)
            visible: !wideAspect
        }
    ]

    onVisibleChanged: column.reEvalColumns()

    Flickable {
        id: projectsList
        anchors.fill: parent

        contentWidth: width
        contentHeight: column.contentHeight + units.gu(2)

        Item {
            width: projectsList.width
            height: column.contentHeight + units.gu(2)
            ColumnFlow {
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: units.gu(1)
                }
                repeaterCompleted: true
                columns: extraWideAspect ? 3 : wideAspect ? 2 : 1

                Timer {
                    interval: 100
                    running: true
                    onTriggered: {
                        print("Triggered!")
                        column.repeaterCompleted = true
                        column.reEvalColumns()
                    }
                }

                SettingsTile {
                    title: "GitHub Projects"
                    iconSource: "github"

                    Repeater {
                        model: backend.projects
                        delegate: ProjectListItem {
                            project: modelData
                            visible: project.hasPlugin("GitHub")
                            subText: project.getPlugin("GitHub").repo
                        }
                    }

                    onHeightChanged: column.reEvalColumns()
                }

                SettingsTile {
                    title: "Launchpad Projects"

                    Repeater {
                        model: backend.projects
                        delegate: ProjectListItem {
                            project: modelData
                            visible: !project.hasPlugin("GitHub") && project.hasPlugin("Launchpad")
                        }
                    }
                    onHeightChanged: column.reEvalColumns()
                }

                SettingsTile {
                    title: "Local Projects"
                    iconSource: "cube"

                    Repeater {
                        model: backend.projects
                        delegate: ProjectListItem {
                            project: modelData
                            visible: !project.hasPlugin("GitHub") && !project.hasPlugin("Launchpad")
                        }
                    }
                    onHeightChanged: column.reEvalColumns()
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent
        visible: backend.projects.count === 0
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
            action: inboxAction
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
