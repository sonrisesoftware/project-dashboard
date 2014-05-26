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

import "../../components"
import "../../backend"
import "../../ubuntu-ui-extras/listutils.js" as List
import "../../ubuntu-ui-extras"

PluginItem {
    id: plannerView

    title: "Planner"

    property string view: plugin.doc.get("plannerView", "component") // or "label" or "assignee" or "milestone" (and later, "status")

    property var columns: view === "component" ? componentColumns : view === "assignee" ? assigneeColumns : view === "milestone" ? milestoneColumns : []
    property var filter: view === "component" ? componentFilter : view === "assignee" ? assigneeFilter : view === "milestone" ? milestoneFilter : []

    // Component view

    property var componentColumns: {
        var list = JSON.parse(JSON.stringify(plugin.components))
        list.sort()
        list.splice(0, 0, "Uncategorized")
        return list
    }

    function componentFilter(column) {
        return List.filter(plugin.issues, function(issue) {
                            return !issue.isPullRequest && issue.open && ((column === "Uncategorized" && issue.title.match(/\[.*\].*/) === null) || issue.title.indexOf("[" + column + "]") == 0)
                        }).sort(function(a, b) { return b.number - a.number })
    }

    // Milestone view

    property var milestoneColumns: {
        var list = [i18n.tr("No Milestone")]

        for (var i = 0; i < plugin.milestones.length; i++) {
            list.push(plugin.milestones[i].title)
        }

        return list
    }

    function milestoneFilter(column) {
        return List.filter(plugin.issues, function(issue) {
                            return !issue.isPullRequest && issue.open && ((column === i18n.tr("No Milestone") && !issue.hasMilestone) || issue.hasMilestone && issue.milestone.title == column)
                        }).sort(function(a, b) { return b.number - a.number })
    }

    // Assignee view

    property var assigneeColumns: {
        var list = [i18n.tr("No Assignee")]

        for (var i = 0; i < plugin.availableAssignees.length; i++) {
            list.push(plugin.availableAssignees[i].login)
        }

        return list
    }

    function assigneeFilter(column) {
        return List.filter(plugin.issues, function(issue) {
                            return !issue.isPullRequest && issue.open && ((column === i18n.tr("No Assignee") && !issue.hasAssignee) || issue.hasAssignee && issue.assignee.login == column)
                        }).sort(function(a, b) { return b.number - a.number })
    }

    page: PluginPage {
        title: "Planner"

        property int columnCount: Math.max(1, Math.floor(width/units.gu(60)))



        actions: Action {
            text: i18n.tr("View")
            iconSource: getIcon("navigation-menu")
            onTriggered: {
                PopupUtils.open(viewPopover, value)
            }
        }

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: units.gu(1)

            orientation: columnCount > 1 ? Qt.Horizontal : Qt.Vertical

            snapMode: ListView.SnapToItem

            model: columns
            delegate: GridTile {
                id: _tile
                title: modelData

                width: listView.width/columnCount

                maxHeight: columnCount > 1 ? listView.height : -1

                property string column: modelData

                visible: true

                value: issues.length === 1 ? i18n.tr("<b>1</b> issue") : i18n.tr("<b>%1</b> issues").arg(issues.length)

                property var issues: filter(_tile.column)

                Repeater {
                    model: _tile.issues
                    delegate: IssueListItem {
                        issue: modelData
                        showDivider: index < _tile.issues.length - 1
                    }
                }

                ListItem.Standard {
                    visible: _tile.issues.length === 0
                    enabled: false

                    text: i18n.tr("No issues")
                    showDivider: true
                }
            }
        }

        Scrollbar {
            flickableItem: listView
        }

        Component {
            id: viewPopover

            Popover {
                id: _viewPopover
                Column {
                    width: parent.width

                    ListItem.Header {
                        text: i18n.tr("Group By")
                    }

                    OverlayItemSelector {
                        id: _viewSelector
                        expanded: true
                        model: [
                            {
                                title: i18n.tr("Component"),
                                name: "component"
                            },
                            {
                                title: i18n.tr("Milestone"),
                                name: "milestone"
                            },
                            {
                                title: i18n.tr("Assignee"),
                                name: "assignee"
                            }
                        ]

                        selectedIndex: {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i].name == plannerView.view)
                                    return i
                            }

                            return 0
                        }

                        onSelectedIndexChanged: {
                            plannerView.view = model[selectedIndex].name
                        }

                        delegate: OverlayItemSelectorDelegate {
                            text: modelData.title

                            onClicked: {
                                PopupUtils.close(_viewPopover)
                            }
                        }
                    }
                }
            }
        }
    }
}
