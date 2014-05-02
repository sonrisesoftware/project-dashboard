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

import "../../qml-air"
import "../../qml-air/ListItems" as ListItem

import "../../components"
import "../../qml-extras/listutils.js" as List
import ".."

PluginPage {
    id: page
    title: i18n.tr("Pull Requests")

    property var plugin

    property var allIssues: List.filter(plugin.issues, function(issue) {
        return issue.isPullRequest
    }).sort(function(a, b) { return b.number - a.number })

    actions: [
        Action {
            id: newIssueAction
            iconName: "plus"
            name: i18n.tr("New Pull")
            onTriggered: PopupUtils.open(Qt.resolvedUrl("NewPullRequestsPage.qml"), plugin, {repo: repo, action: reload})
        },

        Action {
            id: filterAction
            name: i18n.tr("Filter")
            //iconSource: getIcon("filter")
            onTriggered: filterPopover.show()
            //visible: !wideAspect
        }
    ]

    ListView {
        id: listView
        anchors {
            right: parent.right
            left: sidebar.right
            top: parent.top
            bottom: parent.bottom
        }
        model: allIssues
        delegate: PullRequestListItem {
            issue: modelData
            show: selectedFilter(issue)
        }
        clip: true
    }

    Label {
        anchors.centerIn: listView
        text: settings.get("showClosedTickets", false) ? i18n.tr("No pull requests") : i18n.tr("No open pull requests")
        visible: List.filteredCount(allIssues, selectedFilter) === 0
        fontSize: "large"
        opacity: 0.5
    }

    property var selectedFilter: allFilter

    function filter(issue) {
        return (issue.open || settings.get("showClosedTickets", false))
    }

    property var allFilter: function(issue) {
        return filter(issue) ? true : false
    }

    property var createdFilter: function(issue) {
        return issue.user && issue.user.login === github.user.login && filter(issue) ? true : false
    }

    ScrollBar {
        flickableItem: listView
    }

    Sidebar {
        id: sidebar
        width: units.gu(27)
        expanded: wideAspect
        Item {
            id: sidebarContents
            width: parent.width
            height: childrenRect.height
        }
    }
}
