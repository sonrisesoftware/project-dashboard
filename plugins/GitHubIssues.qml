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

    title: "Issues"
    iconSource: "bug"
    unread: openIssues.length > 0
    canReload: true

    page: Component { IssuesPage {} }

    action: Action {
        text: i18n.tr("New Issue")
        onTriggered: PopupUtils.open(Qt.resolvedUrl("github/NewIssuePage.qml"), plugin, {repo: repo, action: reload})
    }

    property var info: doc.get("repo", {})
    property var milestones: doc.get("milestones", [])
    property var availableAssignees: doc.get("assignees", [])
    property var availableLabels: doc.get("labels", [])
    property var openIssues: issues.filteredChildren(function(doc) { return doc.info && doc.info.state === "open" }).sort(function(a, b) { return parseInt(b) - parseInt(a) })

    document: Document {
        id: doc
        docId: "github"
        parent: project.document
    }

    property alias issues: issues

    Document {
        id: issues

        docId: "issues"
        parent: doc
    }

    ListItem.Header {
        text: "Recent Issues"
        visible: openIssues.length > 0
    }

    Repeater {
        model: Math.min(openIssues.length, 4)
        delegate: IssueListItem {
            number: Number(openIssues[index])
        }
    }

    ListItem.Standard {
        enabled: false
        visible: openIssues.length === 0
        text: i18n.tr("No open issues")
    }

    viewAllMessage: i18n.tr("View all issues")
    summary: i18n.tr("<b>%1</b> open issues").arg(openIssues.length)
    value: openIssues.length

    property string repo:  project.serviceValue("github")
    property bool hasPushAccess: info.hasOwnProperty("permissions") ? info.permissions.push : false

    onRepoChanged: reload()

    function reload() {
        loading += 2
        github.getIssues(repo, "open", function(has_error, status, response) {
            loading--

            if (has_error)
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download list of issues. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            var json = JSON.parse(response)

            issues.startGroup()
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
            issues.endGroup()
        })

        github.getIssues(repo, "closed", function(has_error, status, response) {
            loading--
            var json = JSON.parse(response)

            issues.startGroup()
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
                    if (info.closed_at)
                        newUnreadItem(i18n.tr("<b>%1</b> closed issue %2").arg(item.assignee.login).arg(item.number),
                                      "",
                                      info.closed_at)
                    issues.newDoc(String(item.number), {"info": item})
                }
            }
            issues.endGroup()
        })
    }
}
