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
import "../backend/utils.js" as Utils
import "../components"
import "../backend/services"
import "../ubuntu-ui-extras"
import "github"

Plugin {
    id: plugin

    title: "Pull Requests"
    shortTitle: "Pulls"
    iconSource: "code-fork"
    unread: issues.length > 0
    canReload: true

    action: Action {
        text: i18n.tr("Open Pull Request")
        onTriggered: PopupUtils.open(Qt.resolvedUrl("github/NewPullRequestPage.qml"), plugin, {repo: repo, branches: branches, action: reload})
    }

    property var openIssues: issues.filteredChildren(function(doc) { return doc.info && doc.info.hasOwnProperty("head") && doc.info.state === "open" }).sort(function(a, b) { return parseInt(b) - parseInt(a) })
    property var branches: doc.get("branches", [])
    property var info: doc.get("repo", {})

    property alias issues: issues

    Document {
        id: issues

        docId: "pullRequests"
        parent: doc
    }

    page: Component { PullRequestsPage {} }

    document: Document {
        id: doc
        docId: "github"
        parent: project.document
    }

    ListItem.Header {
        text: "Recent Pull Requests"
        visible: openIssues.length > 0
    }

    Repeater {
        model: Math.min(openIssues.length, 4)
        delegate: PullRequestListItem {
            number: Number(openIssues[index])
        }
    }

    ListItem.Standard {
        enabled: false
        visible: openIssues.length === 0
        text: i18n.tr("No open pull requests")
    }

    viewAllMessage: i18n.tr("View all pull requests")
    summary: i18n.tr("<b>%1</b> open pull requests").arg(openIssues.length)
    value: openIssues.length

    property string repo:  project.serviceValue("github")

    onRepoChanged: reload()

//    property var pullRequests_TEMP: undefined
//    property var pullRequests_TEMP_2: undefined
//    onLoadingChanged: {
//        if (loading === 0 && pullRequests_TEMP !== undefined) {
//            print("SETTING TO TEMP")
//            doc.set("pullRequests", pullRequests_TEMP)
//        }

//        if (loading === 0 && pullRequests_TEMP_2 !== undefined) {
//            print("SETTING TO TEMP")
//            doc.set("closedPullRequests", pullRequests_TEMP_2)
//        }
//    }

    function reload() {
        loading += 3
        github.getPullRequests(repo, "open", function(has_error, status, response) {
            loading--
            if (has_error) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download list of pull requests. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            } else {
                //print("GitHub Results:", response)
                var json = JSON.parse(response)

                for (var i = 0; i < json.length; i++) {
                    var item = json[i]
                    if (item.hasOwnProperty("pull_request"))
                        continue

                    if (issues.hasChild(String(item.number))) {
                        var issue = issues.getChild(String(item.number))
                        issue.set("info", item)
                    } else {
                        newUnreadItem(i18n.tr("<b>%1</b> opened issue %2").arg(item.user.login).arg(item.number),
                                      "",
                                      info.created_at)
                        issues.newDoc(String(item.number), {"info": item})
                    }
                }
            }
        })

        github.getPullRequests(repo, "closed", function(has_error, status, response) {
            loading--
            if (has_error) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download list of pull requests. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            } else {
                //print("GitHub Results:", response)
                var json = JSON.parse(response)

                for (var i = 0; i < json.length; i++) {
                    var item = json[i]
                    if (item.hasOwnProperty("pull_request"))
                        continue

                    if (issues.hasChild(String(item.number))) {
                        var issue = issues.getChild(String(item.number))
                        issue.set("info", item)
                    } else {
                        newUnreadItem(i18n.tr("<b>%1</b> opened issue %2").arg(item.user.login).arg(item.number),
                                      "",
                                      info.created_at)
                        newUnreadItem(i18n.tr("<b>%1</b> closed issue %2").arg(item.assignee.login).arg(item.number),
                                      "",
                                      info.closed_at)
                        issues.newDoc(String(item.number), {"info": item})
                    }
                }
            }
        })

        github.getBranches(repo, function(has_error, status, response) {
            loading--
            print("Branches:", response)
            var json = JSON.parse(response)

            doc.set("branches", json)
        })
    }

    function save() {
        doc.set("pullRequests", issues)
        doc.set("closedPullRequests", closedIssues)
    }
}
