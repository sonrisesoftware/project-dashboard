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
    
    title: project.name

    property alias docId: project.docId

    actions: [
        Action {
            id: configAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
            onTriggered:pageStack.push(Qt.resolvedUrl("ConfigPage.qml"), {project: project})
        }

    ]

    Project {
        id: project
        docId: modelData
    }

    ListView {
        anchors.fill: parent
        model: project.plugins
        spacing: units.gu(2)
        header: Item {
            width: parent.width
            height: units.gu(2)
        }

        footer: Item {
            width: parent.width
            height: units.gu(2)
        }

        delegate: UbuntuShape {
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }
            color: Qt.rgba(0,0,0,0.2)
            height: units.gu(15)
            radius: "medium"

            Label {
                anchors.centerIn: parent
                text: child.get("name")
            }

            Document {
                id: child
                parent: project.document
                docId: modelData
            }
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            action: configAction
        }
    }
}
