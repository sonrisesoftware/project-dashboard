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
import "../ubuntu-ui-extras/listutils.js" as List
import "github"

Plugin {
    id: plugin

    property alias githubPlugin: plugin

    name: "github"
    canReload: false
    configuration: repo ? i18n.tr("Connected to <b>%1</b>").arg(repo) : "Not connected to a repository"

    property string repo: doc.get("repoName", "")
    property bool hasPushAccess: true
    property var milestones: []
    property var availableAssignees: []

    property ListModel issues: ListModel {

    }

    items: [
        PluginItem {
            icon: "bug"
            title: i18n.tr("Issues")
            value: List.filteredCount(issues, function (issue) {
                return !issue.isPullRequest && issue.open
            })
            page: IssuesPage {
                plugin: githubPlugin
            }

            action: Action {
                text: i18n.tr("New Issue")
                description: i18n.tr("Create new issue")
                onTriggered: PopupUtils.open(Qt.resolvedUrl("github/NewIssuePage.qml"), mainView, {repo: repo, action: refresh})
            }

            pulseItem: PulseItem {
                title: i18n.tr("Issues Assigned to Me")
                visible: repeater.count > 0

                Repeater {
                    id: repeater
                    model: List.filter(issues, function(issue) {
                        return !issue.isPullRequest && issue.assignedToMe && issue.open
                    }).sort(function(a, b) { return b.number - a.number })
                    delegate: IssueListItem {
                        showAssignee: false
                        issue: modelData
                    }
                }
            }
        },

        PluginItem {
            icon: "code-fork"
            title: i18n.tr("Pull Requests")
            value: List.filteredCount(issues, function (issue) {
                return issue.isPullRequest && issue.open
            })

            action: Action {
                text: i18n.tr("Open Pull Request")
                description: i18n.tr("Open a new pull request")
                enabled: false
                onTriggered: PopupUtils.open(Qt.resolvedUrl("github/NewPullRequestPage.qml"), mainView, {repo: repo, action: refresh})
            }

            pulseItem: PulseItem {
                title: i18n.tr("Open Pull Requests")
                visible: pullsRepeater.count > 0

                Repeater {
                    id: pullsRepeater
                    model: List.filter(issues, function(issue) {
                        return issue.isPullRequest && issue.open
                    }).sort(function(a, b) { return b.number - a.number })
                    delegate: PullRequestListItem {
                        issue: modelData
                    }
                }
            }
        }
    ]

    onSave: {
        // Save projects
        var list = []
        for (var i = 0; i < issues.count; i++) {
            var issue = issues.get(i).modelData
            list.push(issue.toJSON())
        }

        doc.set("issues", list)
    }

    onLoaded: {
        print("Loading!")

        var list = doc.get("issues", [])
        for (var i = 0; i < list.length; i++) {
            var issue = issueComponent.createObject(mainView, {info: list[i].info})
            issue.fromJSON(list[i])
            issues.append({"modelData": issue})
        }

        refresh()
    }

    function setup() {
        PopupUtils.open(Qt.resolvedUrl("github/RepositorySelectionSheet.qml"), mainView, {plugin: plugin})
    }

    function refresh() {
        print("Refreshing")
        if (!repo)
            return

        var lastRefreshed = doc.get("lastRefreshed", "")

        var handler = function(status, response) {
            if (status === 304)
                return

            //print(response)
            var json = JSON.parse(response)
            //print("LENGTH:", json.length)
            for (var i = 0; i < json.length; i++) {
                var found = false
                for (var j = 0; j < issues.count; j++) {
                    //print(issues.get(j).modelData.number + " === " + json[i].number)
                    if (issues.get(j).modelData.number === json[i].number) {
                        issues.get(j).modelData.info = json[i]
                        found = true
                        break
                    }
                }

                if (!found) {
                    var issue = issueComponent.createObject(mainView, {info: json[i]})
                    issues.append({"modelData": issue})

                    if (lastRefreshed !== "") {
                        if (issue.isPullRequest) {
                            project.newMessage("github", "code-fork", i18n.tr("<b>%1</b> opened pull request %2").arg(issue.user.login).arg(issue.number), issue.title, issue.created_at, issue.info)
                        } else {
                            project.newMessage("github", "bug", i18n.tr("<b>%1</b> opened issue %2").arg(issue.user.login).arg(issue.number), issue.title, issue.created_at, issue.info)
                        }
                    }
                }
            }
        }

        github.getIssues(repo, "open", lastRefreshed,  handler)
        github.getIssues(repo, "closed", lastRefreshed, handler)
        github.getPullRequests(repo, "open", lastRefreshed,  handler)
        github.getPullRequests(repo, "closed", lastRefreshed, handler)

        doc.set("lastRefreshed", new Date().toJSON())
    }

    Component {
        id: issueComponent

        Issue {

        }
    }

    Timer {
        interval: 2 * 60 * 1000 // 2 minutes
        running: true
        repeat: true
        onTriggered: refresh()
    }
}
