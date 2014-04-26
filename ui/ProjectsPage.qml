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
import "../backend"
import "../qml-air"
import "../qml-air/ListItems" as ListItem

Page {
    id: page
    
    title: i18n.tr("Projects")
    objectName: "projectsPage"

    // Needs custom property to show up in autopilot tests
    property bool test: true

    ListView {
        id: projectsList
        anchors.fill: parent
        model: backend.projects
        delegate: ListItem.SingleValue {
            id: projectDelegate
            text: project.name
            value: project.inbox.count > 0 ? project.inbox.count : ""
            onClicked: pageStack.push(Qt.resolvedUrl("ProjectPage.qml"), {project: project})

            height: units.gu(6)
            fontSize: "medium"

            property Project project: modelData

            removable: true
//            confirmRemoval: true

            backgroundIndicator: ListItemBackground {
                state: swipingState
                iconName: "trash"
                text: "Delete"
            }

            onItemRemoved: {
                print("Item removed")
                project.remove()
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

    ScrollBar {
        flickableItem: projectsList
    }
}
