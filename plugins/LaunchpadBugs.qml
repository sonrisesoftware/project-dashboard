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

    title: "Bugs"
    iconSource: "bug"
    unread: issues.length > 0

    page: Component { IssuesPage {} }

    ListItem.Header {
        text: "Recent Issues"
        visible: issues.length > 0
    }

    action: Action {
        text: i18n.tr("New Bug")
        onTriggered: pageStack.push(Qt.resolvedUrl("launchpad/NewIssuePage.qml"), {repo: repo, action: reload})
    }

    property var issues: doc.get("issues", [])

    document: Document {
        id: doc
        docId: backend.getPlugin("launchpad").docId
        parent: project.document
    }

    Repeater {
        model: Math.min(issues.length, 4)
        delegate: IssueListItem {
            property var modelData: issues[index]
        }
    }

    ListItem.Standard {
        enabled: false
        visible: !issues || !issues.hasOwnProperty("length") || issues.length === 0
        text: i18n.tr("No open bugs")
    }

    viewAllMessage: i18n.tr("View all bugs")
    summary: i18n.tr("<b>%1</b> open bugs").arg(issues.length)

    property string repo:  project.serviceValue("launchpad")

    onRepoChanged: reload()

    function reload() {
        loading += 1
        launchpad.getBugs(repo, function(has_error, status, response) {
            loading--
            if (has_error)
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download list of issues. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            print("Launchpad Results:", JSON.stringify(response[0]))
//            var json = JSON.parse(response)
//            var list = []
//            for (var i = 0; i < json.length; i++) {
//                var item = json[i]
//                if (!item.hasOwnProperty("pull_request"))
//                    list.push(item)
//            }

//            doc.set("issues", list)
        })
    }
}
