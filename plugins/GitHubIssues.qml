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
import "../components"
import "../backend/services"
import "../ubuntu-ui-extras"

Plugin {
    id: root

    title: "GitHub Issues"
    iconSource: "bug"
    unread: issues.length > 0

    onClicked: pageStack.push(issuesPage)

    ListItem.Header {
        text: "Recent Issues"
        visible: issues.length > 0
    }

    action: Action {
        text: i18n.tr("New Issue")
        onTriggered: pageStack.push(Qt.resolvedUrl("github/NewIssuePage.qml"), {repo: repo})
    }

    property var issues: doc.get("issues", [])

    Document {
        id: doc
        docId: backend.getPlugin("github").docId
        parent: root.project.document
    }

    Repeater {
        model: Math.min(issues.length, 4)
        delegate: ListItem.Standard {
            property var modelData: issues[index]
            text: "<b>#" + modelData.number + "</b> - " + modelData.title
            onClicked: pageStack.push(Qt.resolvedUrl("github/IssuePage.qml"), {issue: modelData})
        }
    }

    ListItem.Standard {
        enabled: false
        visible: issues.length === 0
        text: "No open issues"
    }

    ListItem.Standard {
        text: "View all issues"
        progression: true
        showDivider: false
        onTriggered: pageStack.push(issuesPage)
    }

    property string repo:  project.serviceValue("github")

    onRepoChanged: github.getIssues(repo, function(response) {
        print("GitHub Results:", response)
        doc.set("issues", JSON.parse(response))
    })

    Component {
        id: issuesPage

        Page {
            title: i18n.tr("Issues")

            Action {
                id: newIssueAction
                iconSource: getIcon("add")
                text: i18n.tr("New Issue")
                onTriggered: pageStack.push(Qt.resolvedUrl("github/NewIssuePage.qml"), {repo: repo})
            }

            ListView {
                id: listView
                anchors.fill: parent
                model: issues.length
                delegate: ListItem.Standard {
                    property var modelData: issues[index]
                    text: "<b>#" + modelData.number + "</b> - " + modelData.title
                    onClicked: pageStack.push(Qt.resolvedUrl("github/IssuePage.qml"), {issue: modelData})
                }
            }

            tools: ToolbarItems {
                opened: wideAspect
                locked: wideAspect

                onLockedChanged: opened = locked

                ToolbarButton { action: newIssueAction }
            }
        }
    }
}
