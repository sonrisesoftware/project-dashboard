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
import "../../backend"

PageView {
    id: root

    property int count: project.inbox.count

    property Project project

    MasterDetailView {
        id: listView
        anchors.fill: parent
        model: project.inbox
        noneMessage: i18n.tr("No unread messages!")
        delegate: MessageListItem {
            message: modelData
            project: root.project
        }

        itemSelected: message !== undefined

        property var message: undefined
        property Plugin plugin: message ? project.getPluginForMessage(message) : null

        content: Loader {
            anchors.fill: parent
            sourceComponent: listView.plugin ? listView.plugin.getPreview(listView.message) : null

            property var message: listView.message
        }

        action: Action {
            iconSource: getIcon("edit-clear")
            text: i18n.tr("Clear")
            enabled: project.inbox.count > 0
            onTriggered: {
                project.clearInbox()
            }
        }
    }
}
