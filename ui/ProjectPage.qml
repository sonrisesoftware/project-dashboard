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

    property Project project

    actions: [
        Action {
            id: configAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
            onTriggered:pageStack.push(Qt.resolvedUrl("ConfigPage.qml"), {project: project})
        },

        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconSource: enabled ? getIcon("bell") : getIcon("bell-o")
            enabled: project.inbox.count > 0
            onTriggered: pageStack.push(Qt.resolvedUrl("InboxPage.qml"), {project: project})
        },

        // TODO: Is there a way to enable auto-refresh in a useable and efficient manner?
        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconSource: getIcon("reload")
            onTriggered: project.reload()
        }
    ]

    ListView {
        anchors.fill:parent
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
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent
        visible: project.plugins.count === 0
        opacity: 0.5
        fontSize: "large"
        text: i18n.tr("No plugins")
    }

//    flickable: sidebar.expanded || project.enabledPlugins.length === 0 ? null : listView

//    onFlickableChanged: {
//        if (flickable === null) {
//            listView.topMargin = 0
//            listView.contentY = 0
//        } else {
//            listView.topMargin = units.gu(9.5)
//            listView.contentY = -units.gu(9.5)
//        }
//    }

//    Project {
//        id: project
//        //docId: modelData
//    }

//    property Plugin selectedPlugin
//    property bool wide: sidebar.expanded

//    onWideChanged: {
//        if (!wide && selectedPlugin) {
//            pageStack.push(pushedPage, {plugin: selectedPlugin})
//            selectedPlugin = null
//        }
//    }

//    function displayPlugin(plugin) {
//        if (sidebar.expanded) {
//            selectedPlugin = plugin
//        } else {
//            pageStack.push(pushedPage, {plugin: plugin})
//        }
//    }

//    function displayMessage(message) {
//        var pluginName = message.plugin
//        var plugin = null
//        for (var i = 0; i < column.children.length; i++) {
//            var item = column.children[i]
//            print(item.item.document.docId)
//            if (item.item && item.item.document.docId === pluginName) {
//                plugin = item.item
//                break
//            }
//        }

//        if (!plugin)
//            throw "Unable to find plugin named: " + pluginName

//        plugin.displayMessage(message)
//    }

//    Component {
//        id: pushedPage

//        Page {
//            id: pushedPagePage
//            title: pluginItem.item.title

//            property Plugin plugin
//            property bool wide: sidebar.expanded
//            flickable: pluginItem.item.flickable

//            onWideChanged: {
//                if (wide) {
//                    pageStack.pop()
//                    selectedPlugin = plugin
//                }
//            }

//            Loader {
//                id: pluginItem
//                anchors.fill: parent
//                visible: plugin
//                sourceComponent: plugin ? plugin.page : null
//                property Plugin plugin: pushedPagePage.plugin

//                property Header header: pushedPagePage.header
//            }

//            tools: ToolbarItems {
//                opened: wideAspect
//                locked: wideAspect

//                onLockedChanged: opened = locked

//                Repeater {
//                    model: pluginItem.item.actions
//                    delegate: ToolbarButton {
//                        id: toolbarButton
//                        action: modelData
//                        visible: action.visible
//                        function trigger(value) { action.triggered(toolbarButton) }
//                    }
//                }

//                ToolbarButton {
//                    action: refreshAction
//                    visible: plugin.canReload
//                }
//            }
//        }
//    }

//    Loader {
//        id: pluginPage
//        anchors {
//            left: sidebar.right
//            right: parent.right
//            top: parent.top
//            bottom: parent.bottom
//        }
//        visible: selectedPlugin
//        sourceComponent: selectedPlugin ? selectedPlugin.page : null
//        property Plugin plugin: selectedPlugin
//    }

//    ListView {
//        id: listView
//        anchors.fill: parent
//        visible: !sidebar.expanded
//        model: column.children
//        delegate: ListItem.SingleValue {
//            property var plugin: visible ? modelData.item : null
//            visible: modelData.hasOwnProperty("item") && modelData.item != null
//            enabled: plugin.page
//            height: visible? implicitHeight : 0

//            text: visible ? plugin.title : ""
//            value: visible ? plugin.value : ""

//            progression: true
//            onClicked: displayPlugin(plugin)
//        }
//    }

//    Flickable {
//        id: mainFlickable
//        anchors {
//            left: sidebar.right
//            right: parent.right
//            top: parent.top
//            bottom: parent.bottom
//        }
//        clip: wideAspect
//        visible: selectedPlugin == null && sidebar.expanded
//        contentHeight: contents.height
//        contentWidth: width

//        Item {
//            id: contents
//            width: parent.width
//            height: column.contentHeight + units.gu(2)

//            ColumnFlow {
//                id: column
//                width: parent.width - units.gu(2)
//                height: contentHeight
//                anchors.centerIn: parent
//                model: project.enabledPlugins
//                columns: extraWideAspect ? 3 : wideAspect ? 2 : 1
//                //spacing: units.gu(2)
//                delegate: Item {
//                    width: parent.width
//                    height: loader.height + units.gu(2)

//                    property alias item: loader.item
//                    visible: loader.status == Loader.Ready
//                    opacity: visible ? 1 : 0

//                    Behavior on opacity {
//                        UbuntuNumberAnimation {
//                            duration: UbuntuAnimation.SlowDuration
//                        }
//                    }

//                    Loader {
//                        id: loader
//                        anchors.centerIn: parent
//                        width: parent.width - units.gu(2)
//                        source: Qt.resolvedUrl("../plugins/" + modelData + ".qml")
//                        active: true
//                        onLoaded: {
//                            column.reEvalColumns()
//                        }
//                        asynchronous: true


//                        onHeightChanged: column.reEvalColumns()
//                    }
//                }

//                Timer {
//                    interval: 2
//                    running: true
//                    onTriggered: column.reEvalColumns()
//                }
//            }
//        }
//    }

//    Sidebar {
//        id: sidebar
//        expanded: wideAspect
//        width: units.gu(6)
//        color: Qt.rgba(0.2,0.2,0.2,0.8)

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
//                        size: units.gu(3.5)
//                        color: item.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
//                    }

////                    Label {
////                        anchors.horizontalCenter: parent.horizontalCenter
////                        text: i18n.tr("Overview")
////                        fontSize: "small"
////                        color: item.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
////                    }
//                }
//            }

////            ListItem.Standard {
////                id: inboxItem
////                height: units.gu(7)//width
////                onClicked: selectedPlugin = null
////                selected: selectedPlugin === null

////                Column {
////                    anchors.centerIn: parent
////                    spacing: units.gu(0.5)

////                    AwesomeIcon {
////                        anchors.horizontalCenter: parent.horizontalCenter
////                        name: "inbox"
////                        size: units.gu(3)
////                        color: inboxItem.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText

////                        Rectangle {
////                            color: colors["red"]
////                            width: label.text.length == 1 ? height: label.width + units.gu(1.2)
////                            height: units.gu(2.5)
////                            radius: height/2
////                            border.color: Qt.darker(colors["red"])
////                            antialiasing: true

////                            Label {
////                                id: label
////                                anchors.centerIn: parent
////                                text: "23"
////                            }

////                            anchors {
////                                horizontalCenter: parent.right
////                                verticalCenter: parent.top
////                                verticalCenterOffset: units.gu(1)
////                                horizontalCenterOffset: units.gu(0.5)
////                            }
////                        }
////                    }

////                    Label {
////                        anchors.horizontalCenter: parent.horizontalCenter
////                        text: i18n.tr("Inbox")
////                        fontSize: "small"
////                        color: inboxItem.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
////                    }
////                }
////            }

//            Repeater {
//                model: column.children
//                delegate: ListItem.Standard {
//                    id: pluginSidebarItem
//                    height: visible ? width : 0
//                    visible: modelData.hasOwnProperty("item") && modelData.item != null
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
//                            size: units.gu(3.5)

//                            color: pluginSidebarItem.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
//                        }

////                        Label {
////                            anchors.horizontalCenter: parent.horizontalCenter
////                            text: modelData.item.shortTitle
////                            color: pluginSidebarItem.selected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
////                            fontSize: "small"
////                        }
//                    }
//                }
//            }
//        }
//    }

//    Scrollbar {
//        flickableItem: mainFlickable
//    }

//    Label {
//        anchors.centerIn: parent
//        fontSize: "large"
//        opacity: 0.5
//        text: "No plugins enabled"
//        visible: project.enabledPlugins.length === 0
//    }

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
        }

        ToolbarButton {
            action: inboxAction
        }

        ToolbarButton {
            action: configAction
        }
    }
}
