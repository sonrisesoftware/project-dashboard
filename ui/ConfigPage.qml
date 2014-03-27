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
import "../components"
import "../ubuntu-ui-extras"

Page {
    id: page
    
    title: i18n.tr("Project Configuration")

    property Project project

    Flickable {
        id: flickable
        anchors.fill: parent

        contentWidth: width
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            ListItem.Standard {
                text: i18n.tr("Name")
                control: TextField {
                    color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText
                    text: project.name
                    Component.onDestruction: project.name = text
                }
            }

            ListItem.Header {
                text: i18n.tr("Plugins")
            }

            Repeater {
                model: backend.availablePlugins

                delegate: SubtitledListItem {
                    text: title
                    subText: project.hasPlugin(type) ? project.getPlugin(type).configuration : ""
                    enabled: type !== ""
                    control: Switch {
                        checked: project.hasPlugin(type)
                        onCheckedChanged: {
                            project.enablePlugin(type, checked)
                            checked = Qt.binding(function () {return project.hasPlugin(type)})
                        }
                    }
                }
            }

            Repeater {
                model: backend.availableServices

                delegate: SubtitledListItem {
                    text: modelData.title
                    subText: modelData.isEnabled(project) === "" ? project.hasPlugin(modelData.type) ? project.getPlugin(modelData.type).configuration
                                                                                                     : ""
                                                                 : modelData.isEnabled(project)
                    control: Switch {
                        enabled: modelData.isEnabled(project) === ""
                        onEnabledChanged: {
                            if (!enabled)
                                project.enablePlugin(modelData.type, false)
                        }

                        checked: project.hasPlugin(modelData.type)
                        onCheckedChanged: {
                            project.enablePlugin(modelData.type, checked)
                            checked = Qt.binding(function () {return project.hasPlugin(modelData.type)})
                        }
                    }
                }
            }
        }

    }

    Scrollbar {
        flickableItem: flickable
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }
}
