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

    page: PluginPage {
        title: "Planner"

        property int columnCount: Math.max(1, Math.floor(width/units.gu(60)))

        property var columns: view === "component" ? componentColumns : view === "assignee" ? assigneeColumns : view === "milestone" ? milestoneColumns : []
        property var filter: view === "component" ? componentFilter : view === "assignee" ? assigneeFilter : view === "milestone" ? milestoneFilter : []

        property var allIssues: List.filter(plugin.issues, function(issue) {
            return !issue.isPullRequest
        }).sort(function(a, b) { return b.number - a.number })

        // Component view

        property var componentColumns: {
            var list = JSON.parse(JSON.stringify(plugin.components))
            list.sort()
            list.splice(0, 0, "Uncategorized")
            return list
        }

        function componentFilter(column) {
            return List.filter(plugin.issues, function(issue) {
                                return selectedFilter(issue) && !issue.isPullRequest && ((column === "Uncategorized" && issue.title.match(/\[.*\].*/) === null) || issue.title.indexOf("[" + column + "]") == 0)
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
                                return selectedFilter(issue) && !issue.isPullRequest && ((column === i18n.tr("No Milestone") && !issue.hasMilestone) || issue.hasMilestone && issue.milestone.title == column)
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
                                return selectedFilter(issue) && !issue.isPullRequest && ((column === i18n.tr("No Assignee") && !issue.hasAssignee) || issue.hasAssignee && issue.assignee.login == column)
                            }).sort(function(a, b) { return b.number - a.number })
        }

        actions: Action {
            text: i18n.tr("View")
            iconSource: getIcon("navigation-menu")
            onTriggered: {
                PopupUtils.open(viewPopover, value)
            }
        }

        ListView {
            id: listView
            anchors {
                left: parent.left
                right: sidebar.left
                top: parent.top
                bottom: footer.top
                bottomMargin: columnCount > 1 ? 0 : -units.gu(1)
            }

            anchors.margins: units.gu(1)

            orientation: columnCount > 1 ? Qt.Horizontal : Qt.Vertical

            snapMode: columnCount > 1 ? ListView.SnapToItem : ListView.NoSnap

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
                        Label {
                            text: i18n.tr("Group By")
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: units.gu(1)
                            }

                            color: Theme.palette.normal.overlayText
                        }
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

        property var selectedFilter: allFilter

        function issueFilter(issue) {
            return (issue.open || settings.get("showClosedTickets", false)) && selectedMilestone(issue)
        }

        function selectedMilestone(issue) {
            if (milestoneSelector.selectedIndex < milestoneSelector.model.length - 2)
                return issue.milestone && issue.milestone.number === milestoneSelector.model[milestoneSelector.selectedIndex].number
            else if (milestoneSelector.selectedIndex == milestoneSelector.model.length - 2)
                return !issue.milestone || !issue.milestone.hasOwnProperty("number")
            else
                return true
        }

        property var allFilter: function(issue) {
            return issueFilter(issue) ? true : false
        }

        property var assignedFilter: function(issue) {
            return issue.assignedToMe && issueFilter(issue) ? true : false
        }

        property var createdFilter: function(issue) {
            return issue.user && issue.user.login === github.user.login && issueFilter(issue) ? true : false
        }

        Sidebar {
            id: sidebar
            width: units.gu(30)
            expanded: false
            mode: "right"
            color: Qt.rgba(0.2,0.2,0.2,0.97)
            Item {
                id: sidebarContents
                width: parent.width
                height: childrenRect.height
            }
        }

        DefaultSheet {
            id: filterPopover

            title: i18n.tr("Filter")

            Component.onCompleted: {
                filterPopover.__leftButton.text = i18n.tr("Close")
                filterPopover.__leftButton.color = filterPopover.__rightButton.__styleInstance.defaultColor
                filterPopover.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruSheetStyle.qml"), filterPopover)
            }

            contentsHeight: mainView.height
            Item {
                anchors.fill: parent
                anchors.margins: -units.gu(1)

                Column {
                    id: filterColumn
                    width: parent.width

                    ListItem.Standard {
                        text: i18n.tr("Show closed issues")
                        onClicked: closedCheckbox.triggered(closedCheckbox)
                        CheckBox {
                            id: closedCheckbox
                            anchors {
                                right: parent.right
                                rightMargin: units.gu(1.5)
                                verticalCenter: parent.verticalCenter
                            }

                            style: SuruCheckBoxStyle {}
                            checked: settings.get("showClosedTickets", false)
                            onTriggered: checked = settings.sync("showClosedTickets", checked)
                        }
                    }

                    ListItem.Header {
                        text: i18n.tr("Filter")
                        visible: plannerView.view !== "assignee"
                    }

                    ListItem.SingleValue {
                        text: i18n.tr("Everyone's Issues")
                        selected: allFilter === selectedFilter
                        onClicked: selectedFilter = allFilter
                        value: List.filteredCount(allIssues, allFilter)
                        height: units.gu(5)
                        visible: plannerView.view !== "assignee"
                    }

                    ListItem.SingleValue {
                        text: i18n.tr("Assigned to you")
                        selected: assignedFilter === selectedFilter
                        onClicked: selectedFilter = assignedFilter
                        value: List.filteredCount(allIssues, assignedFilter)
                        height: units.gu(5)
                        visible: plannerView.view !== "assignee"
                    }

                    ListItem.SingleValue {
                        text: i18n.tr("Created by you")
                        selected: createdFilter === selectedFilter
                        onClicked: selectedFilter = createdFilter
                        value: List.filteredCount(allIssues, createdFilter)
                        height: units.gu(5)
                        visible: plannerView.view !== "assignee"
                    }

                    ListItem.Header {
                        text: i18n.tr("Milestone")
                        visible: plannerView.view !== "milestone"
                    }

                    SuruItemSelector {
                        id: milestoneSelector
                        visible: plannerView.view !== "milestone"
                        model: plugin.milestones.concat(i18n.tr("No milestone")).concat(i18n.tr("Any milestone"))

                        selectedIndex: model.length - 1

                        delegate: OptionSelectorDelegate {
                            text: modelData.title ? modelData.title : modelData
                        }
                    }
                }
            }
        }

        states: [
            State {
                when: sidebar.expanded

                ParentChange {
                    target: filterColumn
                    parent: sidebarContents
                    width: sidebarContents.width
                    x: 0
                    y: 0
                }

                StateChangeScript {
                    script: {
                        filterPopover.hide()
                    }
                }
            }
        ]

        Rectangle {
            id: footer
            anchors {
                left: parent.left
                right: sidebar.left
                bottom: parent.bottom
            }

            height: units.gu(9)

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Qt.rgba(0,0,0,0)
                }

                GradientStop {
                    position: 1
                    color: mainView.backgroundColor
                }
            }

            Row {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: units.gu(2)
                }

                spacing: units.gu(1.5)

                ActionButton {
                    iconName: "pencil"
                    color: colors["blue"]
                    onClicked: PopupUtils.open(Qt.resolvedUrl("NewIssuePage.qml"), plugin, {plugin: plugin})
                }

                ActionButton {
                    iconName: "bars"
                    color: colors["orange"]
                    onClicked: PopupUtils.open(viewPopover, caller)
                }

                ActionButton {
                    iconName: sidebar.expanded ? "caret-right" : "filter"
                    color: colors["green"]
                    onClicked: sidebar.toggle()
                }
            }
        }
    }
}
