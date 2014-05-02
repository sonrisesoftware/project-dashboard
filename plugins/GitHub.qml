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
import "../backend"
import "../components"
import "../backend/services"

import "../qml-air"
import "../qml-air/ListItems" as ListItem
import "../qml-extras/listutils.js" as List
import "github"

Plugin {
    id: plugin

    property alias githubPlugin: plugin

    name: "github"
    title: "GitHub"
    icon: "github"
    canReload: false
    configuration: repo ? repo : "Not connected to a repository"

    property string repo: doc.get("repoName", "")

    property var milestones: doc.get("milestones", [])
    property var info: doc.get("repo", {})
    property var availableAssignees: doc.get("assignees", [])
    property var availableLabels: doc.get("labels", [])
    property var branches: doc.get("branches", [])
    property var commitStats: doc.get("commit_stats", {})
    property var releases: doc.get("releases", [])
    property bool hasPushAccess: info.permissions ? info.permissions.push : false
    property bool isFork: info.fork

    property int nextNumber: doc.get("nextNumber", 1)

    property ListModel issues: ListModel {

    }

    property var openPulls: List.filter(issues, function(issue) {
        return issue.isPullRequest && issue.open
    }).sort(function(a, b) { return b.number - a.number })

    property var openIssues: List.filter(issues, function (issue) {
        return !issue.isPullRequest && issue.open
    })

    items: [
        PluginItem {
            id: pluginItem
            icon: "bug"
            title: i18n.tr("Issues")
            value: openIssues.length > 0 ? openIssues.length : ""
            enabled: !isFork
            page: IssuesPage {
                plugin: githubPlugin
            }

            action: Action {
                name: i18n.tr("New Issue")
                description: i18n.tr("Create new issue")
                onTriggered: PopupUtils.open(Qt.resolvedUrl("github/NewIssuePage.qml"), mainView, {plugin: githubPlugin})
            }

            pulseItem: PulseItem {
                title: i18n.tr("Issues Assigned to You")
                viewAll: i18n.tr("View all <b>%1</b> open issues").arg(pluginItem.value)
                show: repeater.count > 0

                ListItem.Standard {
                    text: i18n.tr("No issues assigned to you")
                    enabled: false
                    visible: repeater.count == 0
                    height: visible ? implicitHeight : 0
                }

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
            id: pullsItem
            icon: "code-fork"
            title: i18n.tr("Pull Requests")
            value: openPulls.length > 0 ? openPulls.length : ""

            action: Action {
                name: wideAspect && width < units.gu(90) ? i18n.tr("Open Pull") : i18n.tr("Open Pull Request")
                description: i18n.tr("Open a new pull request")
                onTriggered: PopupUtils.open(Qt.resolvedUrl("github/NewPullRequestPage.qml"), mainView, {plugin: githubPlugin})
            }

            page: PullRequestsPage {
                plugin: githubPlugin
            }

            pulseItem: PulseItem {
                title: i18n.tr("Recently Opened Pull Requests")
                viewAll: i18n.tr("View all <b>%1</b> open pull requests").arg(pullsItem.value)
                show: pullsRepeater.count > 0

                ListItem.Standard {
                    text: i18n.tr("No open pull requests")
                    enabled: false
                    visible: pullsRepeater.count == 0
                    height: visible ? implicitHeight : 0
                }

                Repeater {
                    id: pullsRepeater

                    model: Math.min(openPulls.length, project.maxRecent)
                    delegate: PullRequestListItem {
                        issue: openPulls[index]
                    }
                }
            }
        }
    ]

    onSave: {
        print("Saving", project.name)

        // Save issues
        var start = new Date()
        var list = []
        for (var i = 0; i < issues.count; i++) {
            var issue = issues.get(i).modelData
            list.push(issue.toJSON())
        }

        doc.set("issues", list)
        doc.set("nextNumber", nextNumber)
        var end = new Date()
        print("Average time to save an issue is " + (end - start)/list.length + " milliseconds")
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
        pageStack.open(Qt.resolvedUrl("github/RepositorySelectionSheet.qml"), {plugin: plugin})
    }

    property int syncId: -1

    function refresh() {
        if (!repo)
            return

        var lastRefreshed = doc.get("lastRefreshed", "")

        if (lastRefreshed === "")
            project.loading += 12

        var handler = function(status, response) {
            if (lastRefreshed === "")
                project.loading--

            if (status === 304) {
                if (lastRefreshed === "")
                    throw "Error: cache wasn't emptied for the new GitHub project!"
                return
            }

            plugin.changed = true

            //print(response)
            var json = JSON.parse(response)
            //print("LENGTH:", json.length)
            for (var i = 0; i < json.length; i++) {
                var found = false
                for (var j = 0; j < issues.count; j++) {
                    var issue = issues.get(j).modelData

                    //print(issues.get(j).modelData.number + " === " + json[i].number)
                    if (issue.number === json[i].number) {
                        issue.info = json[i]
                        found = true
                        break
                    }
                }

                if (!found) {
                    var issue = issueComponent.createObject(mainView, {info: json[i]})
                    issue.refresh(syncId)
                    issues.append({"modelData": issue})
                    nextNumber = Math.max(nextNumber, issue.number + 1)
                }
            }
        }

        if (syncId !== -1 && project.syncQueue.groups.hasOwnProperty(syncId)) {
            print("Deleting existing sync operation for GitHub")
            delete project.syncQueue.groups[syncId]
            project.syncQueue.groups = project.syncQueue.groups
        }

        syncId = project.syncQueue.newGroup(i18n.tr("Updating GitHub project"))

        for (var i = 0; i < issues.count; i++) {
            var issue = issues.get(i).modelData
            issue.refresh(syncId)
        }

        github.getPullRequests(project, syncId, repo, "open", lastRefreshed,  handler)
        github.getPullRequests(project, syncId, repo, "closed", lastRefreshed, handler)


        github.getEvents(project, syncId, repo, function (status, response) {
            if (lastRefreshed === "")
                project.loading--

            if (status === 304) {
                if (lastRefreshed === "")
                    throw "Error: cache wasn't emptied for the new GitHub project!"
                return
            }

            plugin.changed = true

            if (lastRefreshed === "")
                return

            var json = JSON.parse(response)

            print("LENGTH:", json.length)
            for (var i = 0; i < json.length; i++) {
                var event = json[i]
                var actor = event.actor.login
                var type = event.type
                var date = event.created_at
                var payload = event.payload

                // TODO: When publishing, add: || actor === github.user.login
                print(date, lastRefreshed, type, actor)
                if (new Date(lastRefreshed) >= new Date(date))
                    break

                if (actor === github.user.login)
                    continue

                // newMessage(plugin, icon, title, message, date, data)
                print(type)

                if (type === "IssuesEvent") {
                    var issue = payload.issue
                    project.newMessage("github", "bug", i18n.tr("<b>%1</b> %2 issue %3")
                                       .arg(actor)
                                       .arg(payload.action)
                                       .arg(issue.number),
                                       issue.title, new Date(date),
                                       {"type": "issue", "number": issue.number})
                } else if (type === "PullRequestEvent") {
                    var pull = payload.pull_request
                    project.newMessage("github", "code-fork", i18n.tr("<b>%1</b> %2 issue %3")
                                       .arg(actor)
                                       .arg(payload.action)
                                       .arg(pull.number),
                                       pull.title, new Date(date),
                                       {"type": "issue", "number": pull.number})
                } else if (type === "IssueCommentEvent") {
                    // TODO: Only display if the actor is other than the authenticated user
                    var issue = payload.issue
                    var comment = payload.comment
                    project.newMessage("github", "comments-o", i18n.tr("<b>%1</b> commented on issue %2")
                                       .arg(actor)
                                       .arg(issue.number),
                                       comment.body, new Date(date),
                                       {"type": "comment", "number": issue.number})
                } else if (type === "PushEvent") {
                    // TODO: Finish push eventss
                    //groupCommitMessages(payload.ref.substring(11), payload.commits)
                } else if (type === "ForkEvent") {
                    var repo = payload.forkee
                    project.newMessage("github", "code-fork", i18n.tr("<b>%1</b> forked %2")
                                       .arg(actor)
                                       .arg(plugin.repo),
                                       i18n.tr("Forked %1 to %2").arg(plugin.repo).arg(repo.full_name), new Date(date),
                                       {"type": "fork"})
                }
            }
        })

        github.getRepository(project, syncId, repo, function(status, response) {
            if (lastRefreshed === "")
                project.loading--
            //print("Info:", response)
            var json = JSON.parse(response)
            doc.set("repo", json)

            if (!isFork) {
                github.getIssues(project, syncId, repo, "open", lastRefreshed,  handler)
                github.getIssues(project, syncId, repo, "closed", lastRefreshed, handler)

                github.getLabels(project, syncId, repo, function(status, response) {
                    if (lastRefreshed === "")
                        project.loading--
                    //print("Labels:", response)
                    var json = JSON.parse(response)
                    doc.set("labels", json)
                })

                github.getAssignees(project, syncId, repo, function(status, response) {
                    if (lastRefreshed === "")
                        project.loading--
                    //print("Labels:", response)
                    var json = JSON.parse(response)
                    doc.set("assignees", json)
                })

                github.getMilestones(project, syncId, repo, function(status, response) {
                    if (lastRefreshed === "")
                        project.loading--
                    //print("Labels:", response)
                    var json = JSON.parse(response)
                    doc.set("milestones", json)
                })


                github.get(project, syncId, "/repos/" + repo + "/releases", function(status, response) {
                    if (lastRefreshed === "")
                        project.loading--
                    doc.set("releases", JSON.parse(response))
                })
            }
        })

        github.get(project, syncId, "/repos/" + repo + "/stats/participation", function(status, response) {
            if (lastRefreshed === "")
                project.loading--
            doc.set("commit_stats", JSON.parse(response))
        })

        github.get(project, syncId, "/repos/" + repo + "/branches", function(status, response) {
            if (lastRefreshed === "")
                project.loading--
            doc.set("branches", JSON.parse(response))
        })

        doc.set("lastRefreshed", new Date().toJSON())
    }

//    function groupCommitMessages(branch, commits) {
//        var groupedCommits
//        var index = 0;
//        var count = 0;
//        while (index < commits.length) {
//            var comment = commit[index]

//            if (event && event.event && event.event === "commit") {
//                index++
//                var login = event.actor.login
//                count = 1
//                while(count < 5 && index < allEvents.length && allEvents[index].event === "commit" && allEvents[index].actor.login === login) {
//                    var nextEvent = allEvents[index]
//                    event.commits = event.commits.concat(nextEvent.commits)
//                    allEvents.splice(index, 1)
//                    count++
//                }

//                index--
//            }

//            index++
//        }
//    }

    Component {
        id: issueComponent

        Issue {

        }
    }

    function newPullRequest(title, description, branch) {
        var number = nextNumber++
        var json = {
            "state": "open",
            "number": number,
            "title": title,
            "body": description,
            "pull_request": {},
            "user": github.user,
            "labels": [],
            "created_at": new Date().toJSON()
        }

        var issue = issueComponent.createObject(mainView, {info: json})
        issues.append({"modelData": issue})
        github.newPullRequest(project, repo, number, title, description, branch)
        notification.show(i18n.tr("Pull request created"))
    }

    function newIssue(title, description) {
        var number = nextNumber++
        var json = {
            "state": "open",
            "number": number,
            "title": title,
            "body": description,
            "user": github.user,
            "labels": [],
            "created_at": new Date().toJSON()
        }

        var issue = issueComponent.createObject(mainView, {info: json})
        issues.append({"modelData": issue})
        github.newIssue(project, repo, number, title, description)
        notification.show(i18n.tr("Issue created"))
    }

    function displayMessage(message) {
        for (var i = 0; i < issues.count;i++) {
            var issue = issues.get(i).modelData
            if (issue.number == message.data.number) {
                pageStack.push(Qt.resolvedUrl("github/IssuePage.qml"), {issue: issue, plugin:plugin})
                return
            }
        }

        throw "Unable to display message: " + JSON.stringify(message)
    }
}
