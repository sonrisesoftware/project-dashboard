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
import "../backend"
import "../components"

import "../qml-extras"
import "../qml-extras/listutils.js" as List
import "../qml-air"
import "../qml-air/ListItems" as ListItem

Page {
    id: page
    
    title: project.name

    property Project project
    property string selectedView: "overview"

    rightWidgets: [
        Repeater {
            id: repeater
            model: tabs.plugin !== null ? tabs.selectedPage.item.page.actions : []
            delegate: Button {
                text: modelData.name
                iconName: modelData.icon
                onClicked: modelData.triggered()
            }
        },

        Button {
            iconName: syncError || noConnection ? "exclamation-triangle" : "spinner-rotate"
            iconColor: noConnection ? theme.warning : syncError ? theme.danger : textColor
            text: noConnection ? "No connection" : syncError ? "Sync error" : "Syncing..."
            opacity: busy || syncError || noConnection ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            onClicked: if (!noConnection) syncPopover.open(caller)
        },

        Button {
            iconName: "cog"
            onClicked: settingsPage.open()
            toolTip: "Settings"
        }
    ]

    function displayPluginItem(pluginItem) {
        pageStack.push(pluginItem.page)
    }

    Item {
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        Item {
            visible: selectedView === "overview"

            anchors.fill: parent

            Item {
                anchors {
                    left: parent.left
                    right: streamSidebar.left
                    top: parent.top
                    bottom: parent.bottom
                }

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
                        color: theme.secondaryColor
                        text: i18n.tr("Add some plugins by tapping \"Edit\" in the toolbar.")
                    }
                }

                Label {
                    anchors.centerIn: parent
                    fontSize: "large"
                    opacity: 0.5
                    text: "Nothing to show"
                }

                Flickable {
                    id: mainFlickable
                    anchors {
            //            fill: parent
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    clip: wideAspect
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
                            model: project.plugins
                            columns: column.width > units.gu(120) ? 3 : column.width > units.gu(60) ? 2 : 1
                            //spacing: units.gu(2)
                            delegate: Repeater {
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
                                        title: tile.pluginItem.title
                                        viewAllMessage: loader.item.viewAll
                                        action: tile.pluginItem.action
                                        anchors.centerIn: parent
                                        width: parent.width - units.gu(2)

                                        onTriggered: {
                                            if (pluginItem.page)
                                                displayPluginItem(pluginItem)
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
                                    print("Triggered!")
                                    column.updateWidths()
                                }
                            }
                        }
                    }
                }

                ScrollBar {
                    flickableItem: mainFlickable
                }
            }

            Sidebar {
                id: streamSidebar
                mode: "right"
                autoFlick: false

                //TODO: Remove once the stream is implemented
                expanded: false

                Rectangle {
                    height: units.gu(4)
                    width: parent.width
                    color: "white"

                    Label {
                        anchors.centerIn: parent
                        fontSize: "large"
                        text: "Stream"
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        anchors.bottom: parent.bottom

                        color: Qt.rgba(0,0,0,0.2)
                    }
                }

                width: units.gu(27)
            }
        }

        InboxPage {
            visible: selectedView == "inbox"

            project: page.project
        }

        Tabs {
            id: tabs
            visible: project.hasPlugin(selectedView)
            anchors.fill: parent

            property Plugin plugin: project.getPlugin(selectedView)

            Repeater {
                model: tabs.plugin !== null ? tabs.plugin.items : []
                delegate: Page {
                    title: modelData.title
                    parent: tabs.tabsContent

                    property PluginItem item: modelData

                    onVisibleChanged: {
                        if (modelData.page) {
                            modelData.page.parent = tabs
                            modelData.page.anchors.fill = tabs.tabsContent
                            modelData.page.visible = visible
                        }
                    }
                }
            }
        }

        SettingsView {
            visible: selectedView == "settings"

            anchors.fill: parent
        }
    }

    Sidebar {
        id: sidebar
        mode: "left"
        style: "dark"
        width: units.gu(8)

        autoFlick: false

        Column {
            width: parent.width

            SidebarItem {
                iconName: "dashboard"
                text: "Pulse"
                selected: selectedView === "overview"
                onClicked: selectedView = "overview"
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

    Component {
        id: actionMenu

        Popover {
            id: actionsPopover
            Column {
                width: parent.width

                Item {
                    width: parent.width
                    height: noneLabel.height + units.gu(4)

                    visible: actionsColumn.height === 0

                    Label {
                        id: noneLabel
                        anchors.centerIn: parent

                        width: parent.width - units.gu(4)
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignHCenter

                        text: i18n.tr("No available actions")
                    }
                }

                Column {
                    id: actionsColumn

                    width: parent.width

                    Repeater {
                        model: project.plugins
                        delegate: Repeater {
                            model: modelData.items
                            delegate: ListItem.Standard {
                                id: actionListItem
                                showDivider: actionListItem.y + actionListItem.height < actionsColumn.height
                                visible: modelData.action
                                enabled: visible ? modelData.action.enabled : false
                                onClicked: {
                                    PopupUtils.close(actionsPopover)
                                    modelData.action.triggered(mainView)
                                }

                                AwesomeIcon {
                                    id: icon
                                    name: modelData.icon
                                    size: units.gu(3.5)
                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: parent.left
                                        leftMargin: units.gu(1.5)
                                    }
                                    opacity: actionListItem.enabled ? 1 : 0.5
                                }

                                Column {
                                    id: labels
                                    opacity: actionListItem.enabled ? 1 : 0.5

                                    spacing: units.gu(0.1)

                                    anchors {
                                        verticalCenter: parent.verticalCenter
                                        left: icon.right
                                        leftMargin: units.gu(1.5)
                                        rightMargin: units.gu(2)
                                        right: parent.right
                                    }

                                    Label {
                                        id: titleLabel

                                        width: parent.width
                                        elide: Text.ElideRight
                                        text: actionListItem.visible ? modelData.action.text : ""
                                    }

                                    Label {
                                        id: subLabel
                                        width: parent.width

                                        height: visible ? implicitHeight: 0
                                        //color:  Theme.palette.normal.backgroundText
                                        maximumLineCount: 1
                                        opacity: 0.75
                                        font.weight: Font.Light
                                        fontSize: "small"
                                        text: actionListItem.visible ? modelData.action.description : ""
                                        visible: text !== ""
                                        elide: Text.ElideRight
                                        color: theme.secondaryColor
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
