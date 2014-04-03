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
        },

        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconSource: enabled ? getIcon("bell") : getIcon("bell-o")
            enabled: project.inbox.count > 0
            onTriggered: pageStack.push(Qt.resolvedUrl("InboxPage.qml"), {project: project})
        },

        Action {
            id: actionsAction
            text: i18n.tr("Actions")
            iconSource: getIcon("navigation-menu")
            onTriggered: PopupUtils.open(actionMenu, value)
        }//,

        // TODO: Is there a way to enable auto-refresh in a useable and efficient manner?
//        Action {
//            id: refreshAction
//            text: i18n.tr("Refresh")
//            iconSource: getIcon("reload")
//            onTriggered: project.reload()
//        }
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

            topMargin: units.gu(12)
            anchors.fill: parent

            model: project.plugins
            delegate: Column {
                property Plugin plugin: modelData
                width: parent.width
                Repeater {
                    model: plugin.items
                    delegate: Loader {
                        width: parent.width
                        height: sourceComponent ? item.height : 0
                        sourceComponent: modelData.pulseItem
                    }
                }
            }
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: header.height/2

            visible: pulseListView.contentHeight === 0
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
                    }
                }
            }
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
    }

    property Flickable oldFlickable

    flickable: wideAspect ? mainFlickable : selectedTab === i18n.tr("Pulse") ? pulseListView : listView

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

    Flickable {
        id: mainFlickable
        anchors {
            fill: parent
//            left: sidebar.right
//            right: parent.right
//            top: parent.top
//            bottom: parent.bottom
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
                        height: pluginTile.height + units.gu(2)
                        visible: pluginItem.pulseItem

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

//    Item {
//        anchors.fill: parent
//        anchors.bottomMargin: header.height - header.__styleInstance.contentHeight
//        parent: header

//        ActivityIndicator {
//            anchors {
//                right: parent.right
//                verticalCenter: parent.verticalCenter
//                rightMargin: (parent.height - height)/2
//            }

//            height: units.gu(4)
//            width: height
//            running: opacity > 0
//            opacity: project.loading ? 1 : 0

//            Behavior on opacity {
//                UbuntuNumberAnimation {
//                    duration: UbuntuAnimation.SlowDuration
//                }
//            }

////            Label {
////                anchors.centerIn: parent
////                text: project.loading
////            }
//        }
//    }

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

//        ToolbarButton {
//            action: refreshAction
//        }

        ToolbarButton {
            action: inboxAction
        }

        ToolbarButton {
            id: actionsButton
            action: actionsAction
            function trigger(value) { action.triggered(actionsButton) }
        }

        ToolbarButton {
            action: configAction
        }
    }
}
