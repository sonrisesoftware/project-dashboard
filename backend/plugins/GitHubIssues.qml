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
import ".."
import "../../components"
import "../services"
import "../../ubuntu-ui-extras"

Plugin {
    id: root

    title: "GitHub Issues"
    iconSource: "bug"
    unread: issues.length > 0

    ListItem.Header {
        text: "Recent Issues"
        visible: issues.length > 0
    }

    property var issues: doc.get("issues", [])

    onProjectChanged: github.getIssues(root.project.services.github, function(response) {
        print("GitHub Results:", response)
        doc.set("issues", JSON.parse(response))
    })

    Document {
        id: doc
        docId: root.project.pluginDocId["githubIssues"]
        parent: root.project.document
    }

    Repeater {
        model: Math.min(issues.length, 4)
        delegate: ListItem.Standard {
            property var modelData: issues[index]
            text: "<b>#" + modelData.number + "</b> - " + modelData.title
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
    }

    GitHub {
        id: github
    }
}
