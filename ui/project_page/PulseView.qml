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

import "../../components"
import "../../ubuntu-ui-extras"
import "../../backend"
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
            text: i18n.tr("No plugins")
        }

        Label {
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            width: parent.width
            text: i18n.tr("Add some plugins by tapping the settings icon in the sidebar.")
        }
    }

    Label {
        anchors.centerIn: parent
        fontSize: "large"
        opacity: 0.5
        text: "Nothing to show"
        visible: column.contentHeight < units.gu(1) && project.plugins.count > 0
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
                columns: extraWideAspect ? 3 : wideAspect ? 2 : 1
                //spacing: units.gu(2)
                delegate: Repeater {
                    id: _pluginItemsRepeater

                    property Plugin plugin: modelData

                    model: plugin.items

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
                            title: tile.pluginItem.title
                            viewAllMessage: loader.item.viewAll
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