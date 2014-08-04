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

import "../../model"
import "../../ubuntu-ui-extras"
import "../../qml-extras/utils.js" as Utils

TabbedPage {
    id: projectPage

    // External properties
    property Project project

    // Page properties
    title: project.name

    // TODO: Could these be better named?
    tabs: sidebar.expanded ? pluginView.tabs : [i18n.tr("Pulse"), i18n.tr("Overview")]

    onTabsChanged: selectedIndex = 0

    showTabs: tabs.length > 0

    head.actions: [
        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconSource: getIcon("reload")
            onTriggered: project.refresh()
        },

        Action {
            id: actionsAction
            objectName: "actionsAction"
            text: i18n.tr("Actions")
            iconSource: getIcon("navigation-menu")
            onTriggered: {
                var caller = Utils.findChild(app.header, "actionsAction_header_button")
                PopupUtils.open(Qt.resolvedUrl("ActionMenu.qml"), caller, {project: projectPage.project})
            }
            visible: sidebar.selectedView === "pulse"
        },

        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconSource: enabled ? getIcon("bell") : getIcon("bell-o")
            enabled: project.inbox.count > 0
            onTriggered: selectedView = "inbox"
            visible: !sidebar.expanded
        },

        Action {
            id: configAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
            onTriggered: pushPageView(Qt.resolvedUrl("ConfigView.qml"), {project: projectPage.project})
            visible: !sidebar.expanded
        }
    ]

    ProjectSidebar {
        id: sidebar
    }

    Item {
        anchors {
            left: sidebar.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        PulseView {
            visible: sidebar.selectedView === "pulse"

            project: projectPage.project
        }

        InboxView {
            visible: sidebar.selectedView === "inbox"

            project: projectPage.project
        }

        ConfigView {
            visible: sidebar.selectedView === "settings"

            project: projectPage.project
        }

        PluginView {
            id: pluginView
            visible: plugin !== null

            project: projectPage.project
        }
    }

    function displayPluginItem(plugin, pluginItem) {
        if (wideAspect) {
            sidebar.selectedView = plugin.type
            pluginView.displayItem(pluginItem)
        } else {
            pushPageView(pluginItem.page)
        }
    }

    function pushPageView(pageView) {
        pageStack.push(pluginPage, {view: pageView})
    }

    Component {
        id: pluginPage

        Page {
            id: _pluginPage
            property Component view

            title: _loader.item.title

            Loader {
                id: _loader
                anchors.fill: parent

                sourceComponent: _pluginPage.view

            }
        }
    }
}
