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

import "../../model"
import "../../qml-extras/listutils.js" as List
import "../../ubuntu-ui-extras"

PageView {
    id: pluginView

    anchors.fill: parent
    property int selectedIndex: 0

    onPluginChanged: selectedIndex = 0

    property Project project

    function displayItem(pluginItem) {
        selectedIndex = List.indexOf(plugin.items, pluginItem)
    }

    property var tabs: {
        if (!plugin) return []

        var list = []
        for (var i = 0; i < pluginView.plugin.pluginView.items.length; i++) {
            list.push(pluginView.plugin.pluginView.items[i].title)
        }
        return list
    }

    property Plugin plugin: project.getPlugin(sidebar.selectedView)

    TabView {
        id: tabView
        anchors.fill: parent

        model: plugin.pluginView.items
        currentIndex: projectPage.selectedIndex


        delegate: Loader {
            width: tabView.width
            height: tabView.height

            sourceComponent: modelData.page

            onItemChanged: {
                if (visible) {
                    pluginView.actions = item.actions
                }
            }

            property Plugin plugin: pluginView.plugin

            Component.onCompleted:  {
                if (visible) {
                    pluginView.actions = item.actions
                }
            }
        }
    }
}
