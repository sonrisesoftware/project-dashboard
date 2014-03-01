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
import "github"

Plugin {
    id: plugin

    title: "Pull Requests"
    shortTitle: "Pulls"
    iconSource: "code-fork"
    unread: issues.length > 0

    ListItem.Header {
        text: "Recent Pull Requests"
        visible: issues.length > 0
    }

    property var issues: doc.get("pullRequests", [])

    document: Document {
        id: doc
        docId: backend.getPlugin("github").docId
        parent: plugin.project.document
    }

    Repeater {
        model: Math.min(issues.length, 4)
        delegate: PullRequestListItem {
            property var modelData: issues[index]
        }
    }

    ListItem.Standard {
        enabled: false
        visible: !issues || !issues.hasOwnProperty("length") || issues.length === 0
        text: i18n.tr("No open pull requests")
    }

    viewAllMessage: i18n.tr("View all pull requests")
    summary: i18n.tr("<b>%1</b> open pull requests").arg(issues.length)

    property string repo:  project.serviceValue("github")

    onRepoChanged: reload()

    property var pullRequests_TEMP: undefined
    onLoadingChanged: {
        if (loading === 0 && pullRequests_TEMP !== undefined) {
            print("SETTING TO TEMP")
            doc.set("pullRequests", pullRequests_TEMP)
        }
    }

    function reload() {
        loading += 1
        github.getPullRequests(repo, function(has_error, status, response) {
            loading--
            if (has_error) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download list of pull requests. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            } else {
                //print("GitHub Results:", response)
                var issues = JSON.parse(response)
                pullRequests_TEMP = issues

                for (var i = 0; i < issues.length; i++) {
                    var issue = issues[i]
                    loading++
                    github.get(issue._links.statuses.href, function(has_error, status, response) {
                        print(response)
                        if (JSON.parse(response)[0] === undefined) {
                            issue.status = {"state": "pending"}
                        } else {
                            issue.status = JSON.parse(response)[0]
                        }
                        print(issue.status.state)

                        pullRequests_TEMP = issues

                        loading--
                    })
                }
            }
        })
    }
}
