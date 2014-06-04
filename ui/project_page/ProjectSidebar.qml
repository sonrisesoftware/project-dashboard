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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem

import "../../ubuntu-ui-extras"
import "../../components"

Sidebar {
    id: sidebar
    expanded: wideAspect
    width: Math.min(units.gu(8), height/(project.plugins.count + 4))
    color: Qt.rgba(0,0,0,0.4)
    dividerColor: Qt.rgba(0,0,0,0.4)

    autoFlick: false

    property string selectedView: "pulse"

    Column {
        id: sidebarColumn
        width: parent.width

        SidebarItem {
            iconName: "dashboard"
            text: "Pulse"
            selected: selectedView === "pulse"
            onClicked: selectedView = "pulse"
        }

        SidebarItem {
            iconName: "inbox"
            text: "Inbox"
            count: project.inbox.count
            selected: selectedView === "inbox"
            onClicked: selectedView = "inbox"
        }

        Repeater {
            model: project.plugins
            delegate: SidebarItem {
                iconName: modelData.icon
                text: modelData.title
                onClicked: selectedView = modelData.type
                selected: selectedView === modelData.type
            }
        }
    }

    SidebarItem {
        iconName: "cog"
        text: "Settings"
        anchor: Qt.TopEdge

        selected: selectedView === "settings"
        onClicked: selectedView = "settings"

        anchors.bottom: parent.bottom
    }
}
