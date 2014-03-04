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
import "../components"

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
        },

        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconSource: getIcon("reload")
            onTriggered: project.reload()
        }
    ]

    flickable: sidebar.expanded || project.enabledPlugins.length === 0 ? null : mainFlickable

    onFlickableChanged: {
        if (flickable === null) {
            mainFlickable.topMargin = 0
            mainFlickable.contentY = 0
        } else {
            mainFlickable.topMargin = units.gu(9.5)
            mainFlickable.contentY = -units.gu(9.5)
        }
    }

    Project {
        id: project
        docId: modelData
    }

    property Plugin selectedPlugin
    property bool wide: sidebar.expanded

    onWideChanged: {
        if (!wide && selectedPlugin) {
            pageStack.push(pushedPage, {plugin: selectedPlugin})
            selectedPlugin = null
        }
    }

    function displayPlugin(plugin) {
        if (sidebar.expanded) {
            selectedPlugin = plugin
        } else {
            pageStack.push(pushedPage, {plugin: plugin})
        }
    }

    Component {
        id: pushedPage

        Page {
            id: pushedPagePage
            title: pluginItem.item.title

            property Plugin plugin
            property bool wide: sidebar.expanded
            flickable: pluginItem.item.flickable

            onWideChanged: {
                if (wide) {
                    pageStack.pop()
                    selectedPlugin = plugin
                }
            }

            Loader {
                id: pluginItem
                anchors.fill: parent
                visible: plugin
                sourceComponent: plugin ? plugin.page : null
                property Plugin plugin: pushedPagePage.plugin

                property Header header: pushedPagePage.header
            }

            tools: ToolbarItems {
                opened: wideAspect
                locked: wideAspect

                onLockedChanged: opened = locked

                Repeater {
                    model: pluginItem.item.actions
                    delegate: ToolbarButton {
                        id: toolbarButton
                        action: modelData
                        visible: action.visible
                        function trigger(value) { action.triggered(toolbarButton) }
                    }
                }

                ToolbarButton {
                    action: refreshAction
                }
            }
        }
    }

    Loader {
        id: pluginPage
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        visible: selectedPlugin
        sourceComponent: selectedPlugin ? selectedPlugin.page : null
        property Plugin plugin: selectedPlugin
    }

    Flickable {
        id: mainFlickable
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        clip: wideAspect
        visible: selectedPlugin == null
        contentHeight: contents.height
        contentWidth: width

        Item {
            id: contents
            width: parent.width
            height: column.contentHeight + units.gu(2)

            ColumnFlow {
                id: column
                width: parent.width - units.gu(2)
                height: contentHeight
                anchors.centerIn: parent
                model: project.enabledPlugins
                columns: extraWideAspect ? 3 : wideAspect ? 2 : 1
                //spacing: units.gu(2)
                delegate: Item {
                    width: parent.width
                    height: loader.height + units.gu(2)

                    property alias item: loader.item

                    Loader {
                        id: loader
                        anchors.centerIn: parent
                        width: parent.width - units.gu(2)
                        source: Qt.resolvedUrl("../plugins/" + modelData + ".qml")
                        onLoaded: {
                            column.reEvalColumns()
                        }

                        onHeightChanged: column.reEvalColumns()
                    }
                }

                Timer {
                    interval: 2
                    running: true
                    onTriggered: column.reEvalColumns()
                }
            }
        }
    }

    Sidebar {
        id: sidebar
        expanded: false//wideAspect
        width: units.gu(8)
        color: Qt.rgba(0.2,0.2,0.2,0.8)

//        Column {
//            width: parent.width

//            ListItem.Standard {
//                id: item
//                height: width
//                onClicked: selectedPlugin = null
//                selected: selectedPlugin === null

//                Column {
//                    anchors.centerIn: parent
//                    spacing: units.gu(0.5)

//                    AwesomeIcon {
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        name: "dashboard"
//                        size: units.gu(3)
//                        color: item.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
//                    }

//                    Label {
//                        anchors.horizontalCenter: parent.horizontalCenter
//                        text: i18n.tr("Pulse")
//                        color: item.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
//                    }
//                }
//            }

//            Repeater {
//                model: column.children
//                delegate: ListItem.Standard {
//                    id: pluginSidebarItem
//                    height: visible ? width : 0
//                    visible: modelData.hasOwnProperty("item")
//                    enabled: modelData.item.page
//                    opacity: enabled ? 1 : 0.5
//                    onClicked: selectedPlugin = modelData.item
//                    selected: selectedPlugin === modelData.item

//                    Column {
//                        anchors.centerIn: parent
//                        spacing: units.gu(0.5)

//                        AwesomeIcon {
//                            anchors.horizontalCenter: parent.horizontalCenter
//                            name: modelData.item.iconSource
//                            size: units.gu(3)

//                            color: pluginSidebarItem.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
//                        }

//                        Label {
//                            anchors.horizontalCenter: parent.horizontalCenter
//                            text: modelData.item.shortTitle
//                            color: pluginSidebarItem.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
//                        }
//                    }
//                }
//            }
//        }
    }

    Scrollbar {
        flickableItem: mainFlickable
    }

    Label {
        anchors.centerIn: parent
        fontSize: "large"
        opacity: 0.5
        text: "No plugins enabled"
        visible: project.enabledPlugins.length === 0
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        Repeater {
            model: selectedPlugin ? pluginPage.item.actions : []
            delegate: ToolbarButton {
                id: toolbarButton
                action: modelData
                visible: action.visible
                function trigger(value) { action.triggered(toolbarButton) }
            }
        }

        ToolbarButton {
            action: refreshAction
        }

        ToolbarButton {
            action: configAction
        }
    }
}
