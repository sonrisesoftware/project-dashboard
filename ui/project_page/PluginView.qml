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

PageView {
    id: pluginView

    anchors.fill: parent
    property int selectedIndex: 0

    onPluginChanged: selectedIndex = 0

    property Project project

    function displayItem(pluginItem) {
        selectedIndex = List.indexOf(plugin.items, pluginItem)
    }

    Rectangle {
        anchors.fill: _tabbar
        anchors.bottomMargin: units.dp(2)
        //color: Qt.rgba(0,0,0,0.35)
    }

    ListItem.Empty {
        id: _tabbar
        height: units.gu(4.2) //_repeater.count > 1 ? units.gu(4.2) : 0

        Row {
            id: _row
            anchors.centerIn: parent
            height: parent.height - units.dp(2)

            Repeater {
                id: _repeater
                model: pluginView.plugin ? pluginView.plugin.pluginView.items : []
                delegate: Item {
                    height: _row.height
                    width: _tabbar.width/_repeater.count //_label.width + units.gu(3)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pluginView.selectedIndex = index
                    }

                    Label {
                        id: _label
                        font.pixelSize: units.dp(17)
                        anchors.centerIn: parent
                        text: modelData.title
                    }

                    Rectangle {
                        height: units.dp(2)
                        width: _label.width + units.gu(3)
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom

                        color: UbuntuColors.orange
                        opacity: index === pluginView.selectedIndex ? 1 : 0
                    }
                }
            }
        }
    }


    property Plugin plugin: project.getPlugin(sidebar.selectedView)

    Loader {
        anchors {
            left: parent.left
            right: parent.right
            top: _tabbar.bottom
            bottom: parent.bottom
        }

        sourceComponent: plugin ? plugin.pluginView.items[selectedIndex].page : null

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
