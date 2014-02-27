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
            onAccepted: backend.newProject(value)
        }
    }
}
