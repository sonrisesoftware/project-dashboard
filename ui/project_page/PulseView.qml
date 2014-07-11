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

import "../../components"
import "../../ubuntu-ui-extras"
import "../../plugins"
import "../../model"
import ".."

PageView {
    id: root

    property Project project
    property alias flickableItem: mainFlickable

    Column {
        anchors.centerIn: parent
        width: parent.width - units.gu(3)
        visible: project.plugins.count === 0
        //opacity: 0.7

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            fontSize: "large"
            font.bold: true
            opacity: 0.8
            text: i18n.tr("No plugins")
        }

        Label {
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            opacity: 0.5
            text: i18n.tr("Add some plugins by tapping the settings icon in the sidebar.")
        }
    }

    Column {
        anchors.centerIn: parent
        visible: column.contentHeight < units.gu(1) && project.plugins.count > 0

        Image {
            source: getIcon("pulse")
            width: units.gu(10)
            height: width
            opacity: 0.8
            antialiasing: true
            smooth: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            width: parent.width
            height: units.gu(2)
        }

        Label {
            opacity: 0.8
            fontSize: "large"
            font.bold: true
            text: i18n.tr("No Recent Activity")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            width: parent.width
            height: units.gu(1)
        }

        Label {
            opacity: 0.5
            fontSize: "medium"
            width: root.width - units.gu(4)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            text: i18n.tr("Upcoming todos and events, assigned bugs, and recently created content will appear here")
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Flickable {
        id: mainFlickable

        anchors.fill: parent
        contentHeight: contents.height
        contentWidth: width

        clip: true

        Item {
            id: contents
            width: parent.width
            height: column.contentHeight + units.gu(2)

            ColumnFlow {
                id: column
                width: parent.width - units.gu(2)
                height: contentHeight
                anchors.centerIn: parent
                model: project.plugins
                columns: extraWideAspect ? width/units.gu(45) : wideAspect ? 2 : 1
                //spacing: units.gu(2)
                delegate: Repeater {
                    id: _pluginItemsRepeater

                    property Plugin plugin: modelData

                    model: plugin.pluginView.items

                    delegate: Item {
                        id: tile
                        width: parent.width

                        visible: modelData.enabled && pluginItem.pulseItem && loader.item.show
                        height: visible ? pluginTile.height + units.gu(2) : 0

                        onVisibleChanged: column.reEvalColumns()

                        onHeightChanged: column.reEvalColumns()

                        property PluginItem pluginItem: modelData

                        PluginTile {
                            id: pluginTile
                            iconSource: tile.pluginItem.icon
                            title: loader.item ? loader.item.title : ""
                            viewAllMessage: loader.item ? loader.item.viewAll : ""
                            action: tile.pluginItem.action
                            anchors.centerIn: parent
                            width: parent.width - units.gu(2)

                            onTriggered: {
                                if (pluginItem.page)
                                    projectPage.displayPluginItem(_pluginItemsRepeater.plugin, tile.pluginItem)
                            }

                            Loader {
                                id: loader
                                width: parent.width
                                sourceComponent: tile.pluginItem.pulseItem
                                onLoaded: {
                                    column.reEvalColumns()
                                }
                                onHeightChanged: column.reEvalColumns()

                                property Plugin plugin: _pluginItemsRepeater.plugin

                                property int maxPulseItems: column.columns * 2 - 1
                            }
                        }
                    }
                }

                Timer {
                    interval: 100
                    running: true
                    onTriggered: {
                        //print("Triggered!")
                        column.updateWidths()
                    }
                }
            }
        }
    }

    Scrollbar {
        flickableItem: mainFlickable
    }
}
