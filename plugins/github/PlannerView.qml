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
import "../../qml-extras/listutils.js" as List
import "../../ubuntu-ui-extras"

PluginPage {
    id: plannerView
    title: "Issues"

    property bool expanded: false

    Component.onCompleted: reload()

    property int columnCount: Math.max(1, Math.floor(width/units.gu(60)))

    property var columns: []

    property int issuesCount: plugin.issues.count

    onIssuesCountChanged: reload()

    property var allIssues: []

    property int everyonesIssues: 0
    property int assignedIssues: 0

    property var groupedIssues: { return {} }

    property var filter: defaultFilters[0]

    onFilterChanged: reload()

    property var defaultFilters: [
        {
            'title': 'Android Tickets',

            'columns': ['Michael Spencer', 'Arni Maack', 'Jean Sconyers', 'Sarah Hightower'],
            'group': 'assignee.name',
            'default': 'Not assigned',

            'filter': {'state':['New','In Progress', 'Test'], 'title': 'android'},
            'sort': 'state'
        },
        {
            'title': 'Grouped by component',

            'columns': ['Uncategorized'],
            'group': 'component',
            'default': 'Uncategorized',

            'filter': {'open':'true'},
            'sort': 'state'
        }
    ]

    function reload() {
        var issues = {}
        allIssues = []
        everyonesIssues = 0
        assignedIssues = 0

        for (var i = 0; i < plugin.issues.count; i++) {
            var issue = plugin.issues.at(i)
            var column = issue.get(filter.group)

            if (!column)
                column = filter['default']

            if (!issue.matches(filter.filter))
                continue

            if (issue.open && !issue.isPullRequest) {
                allIssues.push(issue)
                everyonesIssues++

                if (issue.assignedToMe)
                    assignedIssues++
            }

            if (column) {
                if (!issues[column])
                    issues[column] = []
                issues[column].push(issue)
            }
        }

        for (column in issues) {
            if (issues[column])
                issues[column].sort(function(a,b) { return b.number - a.number })
        }

        var list = List.objectKeys(issues)
        list.sort(function (b, a) {
            if (filter.columns.indexOf(a) !== -1 && filter.columns.indexOf(b) !== -1)
                return filter.columns.indexOf(b) - filter.columns.indexOf(a)
            else if (filter.columns.indexOf(a) !== -1)
                return 1
            else if (filter.columns.indexOf(b) !== -1)
                return -1
            else
                return 0
        })

        columns = list

        groupedIssues = issues
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

            width: visible ? listView.width/columnCount : 0

            maxHeight: columnCount > 1 ? listView.height : -1

            property string column: modelData

            visible: issues !== undefined && issues.length > 0

            value: issues.length === 1 ? i18n.tr("<b>1</b> issue") : i18n.tr("<b>%1</b> issues").arg(issues.length)

            property var issues: groupedIssues[_tile.column]

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

                text: i18n.tr("No issues match the selected filter")
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
                        text: i18n.tr("Saved Filters")
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
                    model: defaultFilters

                    selectedIndex: 0

                    onSelectedIndexChanged: {
                        filter = defaultFilters[selectedIndex]
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

    Sidebar {
        id: sidebar
        width: units.gu(30)
        expanded: wideAspect && plannerView.expanded
        mode: "right"
        color: Qt.rgba(0.22,0.22,0.22,0.97)
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

        contentsHeight: app.height
        Item {
            anchors.fill: parent
            anchors.margins: -units.gu(1)

            Column {
                id: filterColumn
                width: parent.width

                ListItem.Header {
                    visible: wideAspect
                    text: i18n.tr("Filter")
                }

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
                        checked: plugin.showClosedTickets
                        onTriggered: {
                            plugin.showClosedTickets = checked
                        }
                    }
                }

                ListItem.SingleValue {
                    text: i18n.tr("Everyone's Issues")
                    selected: allFilter === selectedFilter
                    onClicked: selectedFilter = allFilter
                    value: everyonesIssues
                    height: units.gu(5)
                    visible: plannerView.group !== "assignee"
                }

                ListItem.SingleValue {
                    text: i18n.tr("Assigned to you")
                    selected: assignedFilter === selectedFilter
                    onClicked: selectedFilter = assignedFilter
                    value: assignedIssues
                    height: units.gu(5)
                    visible: plannerView.group !== "assignee"
                }

                ListItem.SingleValue {
                    text: i18n.tr("Created by you")
                    selected: createdFilter === selectedFilter
                    onClicked: selectedFilter = createdFilter
                    value: List.filteredCount(allIssues, createdFilter)
                    height: units.gu(5)
                    visible: plannerView.group !== "assignee"
                }

                ListItem.Header {
                    text: i18n.tr("Milestone")
                    visible: plannerView.group !== "milestone"
                }

                SuruItemSelector {
                    id: milestoneSelector
                    visible: plannerView.group !== "milestone"
                    model: plugin.milestones.concat(i18n.tr("No milestone")).concat(i18n.tr("Any milestone"))

                    selectedIndex: model.length - 1

                    delegate: OptionSelectorDelegate {
                        text: modelData.title ? modelData.title : modelData
                    }
                }

                ListItem.Header {
                    text: i18n.tr("Group By")
                }

                SuruItemSelector {
                    id: groupSelector

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
                            if (model[i].name == plannerView.group)
                                return i
                        }

                        return 0
                    }

                    onSelectedIndexChanged: {
                        plannerView.group = model[selectedIndex].name
                    }

                    delegate: OptionSelectorDelegate {
                        text: modelData.title
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

    property bool searchActive: searchField.focus || searchField.highlighted

    Keys.onPressed: {
        if (event.text !== "" && !searchField.focus) {
            searchField.forceActiveFocus()
            searchField.text = event.text
        }
    }

    Rectangle {
        id: footer
        anchors {
            left: parent.left
            right: sidebar.left
            bottom: parent.bottom
        }
        clip: true

        height: units.gu(8)

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.rgba(0,0,0,0)
            }

            GradientStop {
                position: 0.8
                color: app.backgroundColor
            }
        }

        ActionButton {
            id: searchButton
            iconName: "search"
            color: colors["red"]

            onClicked: searchField.forceActiveFocus()

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: searchActive || parent.width > units.gu(50) ? units.gu(-4.5) : units.gu(1.5)

                Behavior on margins {
                    UbuntuNumberAnimation {}
                }
            }

            opacity: searchActive || parent.width > units.gu(50) ? 0 : 1

            Behavior on opacity {
                UbuntuNumberAnimation {}
            }
        }

        TextField {
            id: searchField
            anchors {
                left: searchButton.right
                verticalCenter: parent.verticalCenter
                margins: units.gu(1.5)
            }

            Component.onCompleted: __styleInstance.backgroundColor = Qt.binding(function() {
                return (searchField.focus || searchField.highlighted) ? Theme.palette.selected.field : Qt.rgba(1,1,1,0.8)
            })

            // hint text
            Label {
                id: hint
                verticalAlignment: Text.AlignVCenter
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: units.gu(1)
                }
                // hint is shown till user types something in the field
                visible: (searchField.text == "") && !searchField.inputMethodComposing
                color: Theme.palette.normal.overlayText
                opacity: 0.8
                fontSize: "medium"
                elide: Text.ElideRight

                text: i18n.tr("Search...")
            }

            opacity: searchActive || parent.width > units.gu(50) ? 1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {}
            }

            width: (searchField.focus || searchField.highlighted) ? parent.width > units.gu(60) ? units.gu(50) : parent.width - anchors.margins - cancelButton.width - units.gu(3) : units.gu(25)

            Behavior on width {
                UbuntuNumberAnimation {}
            }

            Keys.onEscapePressed: {
                searchField.focus = false
            }
        }

        Row {
            id: row
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: searchActive ? -(row.width - cancelButton.width) + units.gu(1.5) : units.gu(1.5)

                Behavior on margins {
                    UbuntuNumberAnimation {}
                }
            }

            spacing: units.gu(1.5)

            ActionButton {
                id: cancelButton
                iconName: "times"
                color: "grey"
                onClicked: searchField.focus = false
                opacity: searchActive ? 1 : 0

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }
            }

            ActionButton {
                iconName: "pencil"
                color: colors["blue"]
                onClicked: pageStack.push(Qt.resolvedUrl("NewIssuePage.qml"), {plugin: plugin})

                opacity: searchActive ? 0 : 1

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }
            }

//            ActionButton {
//                id: searchButton
//                iconName: "search"
//                onClicked: searchActive = !searchActive
//            }

//            TextField {
//                id: searchField
//                anchors {
//                    verticalCenter: parent.verticalCenter
//                }

//                Component.onCompleted: __styleInstance.backgroundColor = Qt.binding(function() {
//                    return (searchField.focus || searchField.highlighted) ? Theme.palette.selected.field : Theme.palette.selected.field
//                })
//                visible: opacity > 0
//                opacity: searchActive ? 1 : 0
//                width: searchActive ? units.gu(30) : 0

//                Behavior on width {
//                    UbuntuNumberAnimation {}
//                }

//                Behavior on opacity {
//                    UbuntuNumberAnimation {}
//                }
//            }

            ActionButton {
                iconName: "bars"
                color: colors["orange"]
                onClicked: PopupUtils.open(viewPopover, caller)

                opacity: searchActive ? 0 : 1

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }
            }

            ActionButton {
                iconName: sidebar.expanded ? "caret-right" : "filter"
                color: colors["green"]
                onClicked: expanded = !expanded

                opacity: searchActive ? 0 : 1

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }
            }
        }
    }
}
