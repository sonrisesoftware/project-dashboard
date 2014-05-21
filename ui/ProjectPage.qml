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

TabbedPage {
    id: page
    
    title: project.name

    tabs: wideAspect ? [i18n.tr("Pulse")] : [i18n.tr("Pulse"), i18n.tr("Overview")]

    property Project project

    selectedIndex: project.selectedTab

    onSelectedIndexChanged: {
        project.selectedTab = selectedIndex
    }

    actions: [
        Action {
            id: configAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
            onTriggered:pageStack.push(Qt.resolvedUrl("ConfigPage.qml"), {project: project})
            visible: !wideAspect
        },

        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconSource: enabled ? getIcon("bell") : getIcon("bell-o")
            enabled: project.inbox.count > 0
            onTriggered: selectedView = "inbox"
            visible: !wideAspect
        },

        Action {
            id: actionsAction
            text: i18n.tr("Actions")
            iconSource: getIcon("navigation-menu")
            onTriggered: PopupUtils.open(actionMenu, value)
            //visible: wideAspect
        },

        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconSource: getIcon("reload")
            onTriggered: project.refresh()
        }
    ]

    Item {
        visible: !wideAspect
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: show ? 0 : -width

            Behavior on leftMargin {
                UbuntuNumberAnimation {}
            }
        }

        width: parent.width

        opacity: show ? 1 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        property bool show: selectedTab === i18n.tr("Pulse")

        ListView {
            id: pulseListView

            anchors.fill: parent
            topMargin: units.gu(12)

            model: project.plugins

            delegate: Column {
                property Plugin plugin: modelData
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }

                Item {
                    width: parent.width
                    height: visible ? units.gu(2) : 0
                    visible: index === 0
                }

                Repeater {
                    model: plugin.items

                    delegate: Item {
                        width: parent.width
                        height: tile.visible ? tile.height + units.gu(2) : 0
                        PluginTile {
                            id: tile
                            iconSource: pluginItem.icon
                            title: pluginItem.title
                            viewAllMessage: loader.item.viewAll
                            action: tile.pluginItem.action
                            width: parent.width
                            visible: loader.item.show

                            property PluginItem pluginItem: modelData

                            onTriggered: {
                                if (pluginItem.page)
                                    pageStack.push(pluginItem.page)
                            }

                            Loader {
                                id: loader
                                width: parent.width
                                sourceComponent: tile.pluginItem.pulseItem
                            }
                        }
                    }
                }
            }
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: header.height/2

            visible: pulseListView.contentHeight === 0 && project.plugins.count > 0
            opacity: 0.5
            spacing: units.gu(1)

            AwesomeIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: "dashboard"
                size: units.gu(7)
            }

            Label {
                fontSize: "large"
                text: i18n.tr("Nothing to show")

                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Item {
        visible: !wideAspect
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: show ? 0 : -width

            Behavior on rightMargin {
                UbuntuNumberAnimation {}
            }
        }

        width: parent.width

        opacity: show ? 1 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {}
        }

        property bool show: selectedTab === i18n.tr("Overview")

        ListView {
            id: listView
            anchors.fill: parent

            model: project.plugins
            delegate: Column {
                property Plugin plugin: modelData
                width: parent.width
                Repeater {
                    model: plugin.items
                    delegate: ListItem.SingleValue {
                        text: modelData.title
                        value: modelData.value
                        progression: modelData.page
                        onClicked: {
                            if (modelData.page)
                                pageStack.push(modelData.page)
                        }
                        visible: modelData.enabled
                        height: visible ? implicitHeight : 0
                    }
                }
            }
        }
    }

    property Flickable oldFlickable

    flickable: wideAspect ? null : selectedTab === i18n.tr("Pulse") ? pulseListView : listView

    onFlickableChanged: {
        if (oldFlickable && wideAspect) {
            oldFlickable.topMargin = 0
            oldFlickable.contentY = 0
        }

        oldFlickable = flickable

        if (flickable != null && header != null) {
            flickable.topMargin = header.height
            flickable.contentY = -header.height
        }
    }

    Item {
        clip: true
        anchors {
            left: sidebar.right
            right: parent.right
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
                text: i18n.tr("Add some plugins by tapping \"Edit\" in the toolbar.")
            }
        }

        Item {
            anchors.fill: parent
            visible: wideAspect

            Label {
                anchors.centerIn: parent
                fontSize: "large"
                opacity: 0.5
                text: "Nothing to show"
                visible: column.contentHeight < units.gu(1) && selectedView === "overview" && project.plugins.count > 0
            }

            InboxPage {
                anchors.fill: parent

                project: page.project

                visible: selectedView === "inbox"
            }

            ConfigView {
                anchors.fill: parent

                project: page.project
                visible: selectedView === "settings"
            }

            Flickable {
                id: mainFlickable

                anchors.fill: parent
                visible: selectedView === "overview"
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
    }

    property string selectedView: "overview"

    Sidebar {
        id: sidebar
        expanded: wideAspect
        width: Math.min(units.gu(8), height/(project.plugins.count + 4))
        color: Qt.rgba(0,0,0,0.4)
        dividerColor: Qt.rgba(0,0,0,0.4)

        autoFlick: false

        Column {
            id: sidebarColumn
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

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

//        Repeater {
//            model: selectedPlugin ? pluginPage.item.actions : []
//            delegate: ToolbarButton {
//                id: toolbarButton
//                action: modelData
//                visible: action.visible
//                function trigger(value) { action.triggered(toolbarButton) }
//            }
//        }

        ToolbarButton {
            action: refreshAction
            visible: action.visible
        }

        ToolbarButton {
            action: inboxAction
            visible: action.visible
        }

        ToolbarButton {
            id: actionsButton
            action: actionsAction
            visible: action.visible
            function trigger(value) { action.triggered(actionsButton) }
        }

        ToolbarButton {
            action: configAction
            visible: action.visible
        }
    }
}
