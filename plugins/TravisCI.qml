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

    title: "Continuous Integration"
    iconSource: "check-circle"

    property var info: doc.get("repo", [])

    document: Document {
        id: doc
        docId: backend.getPlugin("travis").docId
        parent: project.document
    }

    ListItem.SingleValue {
        value: summaryValue
        text: summary
    }

    summary: i18n.tr("Build %1").arg(info.last_build_number)
    summaryValue: info.last_build_status === 0 ? i18n.tr("Passed") : info.last_build_status === 1 ? i18n.tr("Failed") : i18n.tr("Unknown")

    viewAllMessage: "View details"

    property string repo:  project.serviceValue("travis")

    onRepoChanged: reload()

    function statusColor() {

    }

    function reload() {
        loading = true
        travisCI.getRepo(repo, function(response) {
            loading = false
            if (response === -1)
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download results from Travis CI. Check your connection and/or firewall settings."))
            print("Travis CI Results:", response)
            doc.set("repo", JSON.parse(response))
        })
    }
}
