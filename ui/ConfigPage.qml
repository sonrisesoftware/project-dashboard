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
    
    title: i18n.tr("Project Configuration")

    property Project project

    Column {
        anchors.fill: parent

        ListItem.Standard {
            text: i18n.tr("Name")
            control: TextField {
                text: project.name
                onTextChanged: project.name = text
            }
        }

        ListItem.Header {
            text: i18n.tr("Local Plugins")
        }

        Repeater {
            model: backend.availablePlugins

            delegate: ListItem.Standard {
                text: title
                enabled: type !== ""
                control: Switch {
                    checked: project.hasPlugin(name)
                    onCheckedChanged: project.enablePlugin(name, checked)
                }
            }
        }

        ListItem.Header {
            text: i18n.tr("Services")
        }

        Repeater {
            model: backend.availableServices

            delegate: ListItem.Standard {
                enabled: modelData.enabled
                Column {
                    spacing: units.gu(0.1)
                    opacity: parent.enabled ? 1 :0.5

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: units.gu(2)
                        rightMargin: units.gu(1)
                        right: parent.right
                    }

                    Label {
                        width: parent.width
                        elide: Text.ElideRight
                        text: modelData.title
                    }

                    Label {
                        width: parent.width

                        height: visible ? implicitHeight: 0
                        color:  Theme.palette.normal.backgroundText
                        fontSize: "small"
                        //font.italic: true
                        text: project.hasPlugin(modelData.name) ? modelData.status(project.serviceValue(modelData.name)) : ""
                        visible: text !== ""
                        elide: Text.ElideRight
                    }
                }
                control: Switch {
                    checked: project.hasPlugin(modelData.name)
                    onCheckedChanged: {
                        if (checked) {
                            if (!project.hasPlugin(modelData.name)) {
                                modelData.connect(project)
                            }
                        } else {
                            project.enablePlugin(modelData.name, "")
                        }
                        checked = Qt.binding(function() { return project.hasPlugin(modelData.name) })
                    }
                }
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }

    Component {
        id: launchpadDialog

        InputDialog {
            title: i18n.tr("Connect to Launchpad")
            text: i18n.tr("Enter the name of repository on Launchpad you would like to add to your project")
            placeholderText: i18n.tr("name")
            onAccepted: project.enabledPlugin("launchpad", value)
        }
    }
}
