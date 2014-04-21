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
import "../qml-air"
import "../qml-air/ListItems" as ListItem

Page {
    id: page
    
    title: project.name

    property Project project

    rightWidgets: [
        Button {
            iconName: enabled ? "bell" : "bell-o"
            enabled: project.inbox.count > 0
            onClicked: pageStack.push(Qt.resolvedUrl("InboxPage.qml"), {project: project})
            toolTip: project.inbox.count > 0 ? "%1 notifications".arg(project.inbox.count) : "No notifications"
        },

        Button {
            iconName: "bars"
            onClicked: pageStack.open(Qt.resolvedUrl("ConfigPage.qml"), {project: project})
            toolTip: "Project configuration"
        },

        Button {
            iconName: "cog"
            onClicked: settingsPage.open()
            toolTip: "Settings"
        }

    ]

//    actions: [
//        Action {
//            id: configAction
//            text: i18n.tr("Edit")
//            iconSource: getIcon("edit")
//            onTriggered:pageStack.push(Qt.resolvedUrl("ConfigPage.qml"), {project: project})
//        },

//        Action {
//            id: inboxAction
//            text: i18n.tr("Inbox")
//            iconSource: enabled ? getIcon("bell") : getIcon("bell-o")
//            enabled: project.inbox.count > 0
//            onTriggered: pageStack.push(Qt.resolvedUrl("InboxPage.qml"), {project: project})
//        },

//        Action {
//            id: actionsAction
//            text: i18n.tr("Actions")
//            iconSource: getIcon("navigation-menu")
//            onTriggered: PopupUtils.open(actionMenu, value)
//        },

//        Action {
//            id: refreshAction
//            text: i18n.tr("Refresh")
//            iconSource: getIcon("reload")
//            onTriggered: project.refresh()
//        }
//    ]

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
        visible: wideAspect
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
                columns: extraWideAspect ? 3 : wideAspect ? 2 : 1
                //spacing: units.gu(2)
                delegate: Repeater {
                    model: modelData.items

                    delegate: Item {
                        id: tile
                        width: parent.width

                        visible: modelData.enabled && pluginItem.pulseItem
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
                                    pageStack.push(pluginItem.page)
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
                        color: Theme.palette.normal.overlayText
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

                                    color: Theme.palette.normal.overlayText
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
                                        color: Theme.palette.normal.overlayText
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
                                        color: Theme.palette.normal.overlayText
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

//    tools: ToolbarItems {
//        opened: wideAspect
//        locked: wideAspect

//        onLockedChanged: opened = locked

////        Repeater {
////            model: selectedPlugin ? pluginPage.item.actions : []
////            delegate: ToolbarButton {
////                id: toolbarButton
////                action: modelData
////                visible: action.visible
////                function trigger(value) { action.triggered(toolbarButton) }
////            }
////        }

//        ToolbarButton {
//            action: refreshAction
//        }

//        ToolbarButton {
//            action: inboxAction
//        }

//        ToolbarButton {
//            id: actionsButton
//            action: actionsAction
//            function trigger(value) { action.triggered(actionsButton) }
//        }

//        ToolbarButton {
//            action: configAction
//        }
//    }
}
