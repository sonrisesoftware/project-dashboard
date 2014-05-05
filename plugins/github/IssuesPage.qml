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
    title: i18n.tr("Issues")

    property var plugin

    property var allIssues: List.filter(plugin.issues, function(issue) {
        return !issue.isPullRequest
    }).sort(function(a, b) { return b.number - a.number })

    actions: [
        Action {
            id: newIssueAction
            iconName: "plus"
            name: i18n.tr("New Issue")
            onTriggered: pageStack.open(Qt.resolvedUrl("NewIssuePage.qml"), {plugin: plugin})
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
        delegate: IssueListItem {
            issue: modelData
            show: selectedFilter(issue)
        }
        clip: true
    }

    Label {
        anchors.centerIn: listView
        text: settings.get("showClosedTickets", false) ? i18n.tr("No issues") : i18n.tr("No open issues")
        visible: List.filteredCount(allIssues, selectedFilter) === 0
        fontSize: "large"
        opacity: 0.5
    }

    property var selectedFilter: allFilter

    function filter(issue) {
        return (issue.open || settings.get("showClosedTickets", false)) && milestoneFilter(issue)
    }

    function milestoneFilter(issue) {
        if (milestoneSelector.selectedIndex < milestoneSelector.model.length - 2)
            return issue.milestone && issue.milestone.number === milestoneSelector.model[milestoneSelector.selectedIndex].number
        else if (milestoneSelector.selectedIndex == milestoneSelector.model.length - 2)
            return !issue.milestone || !issue.milestone.hasOwnProperty("number")
        else
            return true
    }

    property var allFilter: function(issue) {
        return filter(issue) ? true : false
    }

    property var assignedFilter: function(issue) {
        return issue.assignedToMe && filter(issue) ? true : false
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

        Column {
            width: parent.width

            ListItem.Standard {
                text: i18n.tr("Show closed issues")
                onClicked: closedCheckbox.clicked(closedCheckbox)
                CheckBox {
                    id: closedCheckbox
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(1.5)
                        verticalCenter: parent.verticalCenter
                    }

                    selected: settings.get("showClosedTickets", false)
                    onClicked: selected = settings.sync("showClosedTickets", selected)
                }
            }

            ListItem.Header {
                text: i18n.tr("Filter")
            }

            ListItem.SingleValue {
                text: i18n.tr("Everyone's Issues")
                selected: allFilter === selectedFilter
                onClicked: selectedFilter = allFilter
                value: List.filteredCount(allIssues, allFilter)
            }

            ListItem.SingleValue {
                text: i18n.tr("Assigned to you")
                selected: assignedFilter === selectedFilter
                onClicked: selectedFilter = assignedFilter
                value: List.filteredCount(allIssues, assignedFilter)
            }

            ListItem.SingleValue {
                text: i18n.tr("Created by you")
                selected: createdFilter === selectedFilter
                onClicked: selectedFilter = createdFilter
                value: List.filteredCount(allIssues, createdFilter)
            }

//            ListItem.SingleValue {
//                text: i18n.tr("Mentioning you")
//                value: "1"
//            }

            ListItem.Header {
                text: i18n.tr("Milestone")
            }

            ListItem.ItemSelector {
                id: milestoneSelector
                model: plugin.milestones.concat(i18n.tr("No milestone")).concat(i18n.tr("Any milestone"))

                selectedIndex: model.length - 1

                delegate: OptionDelegate {
                    text: modelData.title || modelData
                }
            }
        }
    }
}
