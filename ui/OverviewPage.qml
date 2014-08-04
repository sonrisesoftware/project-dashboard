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
import "../model"

import "../qml-extras/utils.js" as Utils
import "../ubuntu-ui-extras"
import "../components"
import "../plugins"

Page {
    id: page

    title: i18n.tr("Overview")
    objectName: "projectsPage"

    // Needs custom property to show up in autopilot tests
    property bool test: true

    head.actions: [
        Action {
            id: newProjectAction
            objectName: "newProjectAction"

            text: i18n.tr("New Project")
            iconSource: getIcon("add")
            onTriggered: {
                if (githubPlugin.service.enabled || assemblaPlugin.service.enabled || launchpadPlugin.service.enabled) {
                    var caller = Utils.findChild(app.header, "newProjectAction_header_button")

                    PopupUtils.open(newProjectPopover, caller)
                } else {
                    PopupUtils.open(newProjectDialog, page)
                }
            }
        },

        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconSource: getIcon("inbox")
            onTriggered: sidebar.expanded = !sidebar.expanded
        },

        Action {
            id: settingsAction
            text: i18n.tr("Settings")
            iconSource: getIcon("settings")
            onTriggered: pageStack.push(Qt.resolvedUrl("ui/SettingsPage.qml"))
        }
    ]

    onVisibleChanged: column.reEvalColumns()

    flickable: backend.projects.count > 0 && !sidebar.expanded ? projectsList : null

    onFlickableChanged: if (!flickable) projectsList.topMargin = 0

    Sidebar {
        id: sidebar
        mode: "right"

        expanded: false
        autoFlick: false
        width: extraWideAspect ? units.gu(35) : units.gu(30)
        //color: "#F5F5F5"
        z: 1

        InboxView {
            anchors.fill: parent
        }
    }

    Flickable {
        id: projectsList
        anchors {
            left: parent.left
            right: sidebar.left//.right
            top: parent.top
            bottom: parent.bottom
        }

        clip: true

        contentWidth: width
        contentHeight: column.contentHeight + units.gu(2)

        Item {
            width: projectsList.width
            height: column.contentHeight + units.gu(2)
            ColumnFlow {
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: units.gu(1)
                }
                repeaterCompleted: true
                columns: width/units.gu(45)

                Timer {
                    interval: 100
                    running: true
                    onTriggered: {
                        //print("Triggered!")
                        column.repeaterCompleted = true
                        column.reEvalColumns()
                    }
                }

                Repeater {
                    model: backend.availablePlugins
                    delegate: Repeater {

                        property var plugin: modelData

                        model: modelData.items
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

                                    property Plugin plugin: null
                                    property int maxPulseItems: column.columns * 2 - 1
                                }
                            }
                        }
                    }
                }

                GridTile {
                    title: "Starred Projects"
                    iconSource: "cube"

                    Repeater {
                        model: backend.projects
                        delegate: ProjectListItem {
                            project: modelData
                            visible: project.starred
                        }
                    }
                    onHeightChanged: column.reEvalColumns()
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent
        visible: backend.projects.count === 0

        AwesomeIcon {
            name: "cube"
            size: units.gu(10)
            opacity: 0.8
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
            text: i18n.tr("No projects")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            width: parent.width
            height: units.gu(0.5)
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.width - units.gu(4)
            opacity: 0.5
            fontSize: "medium"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: i18n.tr("Tap the plus icon in the toolbar to create a new project.")
        }
    }

    Scrollbar {
        flickableItem: projectsList
    }

    Component {
        id: newProjectDialog

        InputDialog {
            title: i18n.tr("Create New Project")
            text: i18n.tr("Please enter a name for your new project.")
            placeholderText: i18n.tr("Name")
            onAccepted: {
                var project = backend.addProject(value)
                //pageStack.push(Qt.resolvedUrl("ProjectPage.qml"), {project: project})
                app.toast(i18n.tr("Project created"))
            }
        }
    }

    Component {
        id: newProjectPopover

        Popover {
            id: _newProjectPopover
            Column {
                width: parent.width

                OverlayStandard {
                    text: i18n.tr("Create Local Project")
                    onClicked: {
                        PopupUtils.close(_newProjectPopover)
                        PopupUtils.open(newProjectDialog)
                    }
                }

                OverlayHeader {
                    text: "Connect to Existing Project"
                }

                Repeater {
                    model: backend.availablePlugins
                    delegate: AwesomeListItem {
                        property Service service: modelData.service

                        visible: service && service.enabled
                        iconName: modelData.icon
                        text: modelData.title

                        onClicked: {
                            PopupUtils.close(_newProjectPopover)
                            modelData.createProject()
                        }
                    }
                }
            }
        }
    }
}
