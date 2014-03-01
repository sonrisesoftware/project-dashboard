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

Page {
    title: i18n.tr("Issues")

    property var plugin

    actions: [
        Action {
            id: newIssueAction
            iconSource: getIcon("add")
            text: i18n.tr("New Issue")
            onTriggered: pageStack.push(Qt.resolvedUrl("NewIssuePage.qml"), {repo: plugin.repo, action: plugin.reload})
        },

        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconSource: getIcon("reload")
            onTriggered: plugin.reload()
        }
    ]

    ListView {
        id: listView
        anchors.fill: parent
        model: plugin.allIssues
        delegate: IssueListItem {
            show: modelData.state === "open" || settings.get("showClosedTickets", false)
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        ToolbarButton { action: newIssueAction; width: units.gu(7)}

        ToolbarButton { action: refreshAction }

        ToolbarButton {
            id: viewButton
            text: i18n.tr("View")
            iconSource: getIcon("navigation-menu")
            onTriggered: PopupUtils.open(viewMenu, viewButton)
        }
    }

    Component {
        id: viewMenu

        Popover {
            height: childrenRect.height
            Column {
                width: parent.width

                ListItem.Standard {
                    text: i18n.tr("Show closed issues")
                    control: CheckBox {
                        checked: settings.get("showClosedTickets", false)
                        onClicked: checked = settings.sync("showClosedTickets", checked)
                    }
                }
            }
        }
    }
}