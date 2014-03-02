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
import "travis"

Plugin {
    id: plugin

    title: "Continuous Integration"
    shortTitle: "Testing"
    iconSource: "check-circle"

    property var info: doc.get("repo", [])
    property var builds: doc.get("builds", [])

    document: Document {
        id: doc
        docId: backend.getPlugin("travis").docId
        parent: project.document
    }

    BuildListItem {
        number: info.last_build_number
        status: info.last_build_result
        built_at: info.last_build_finished_at
        message: {
            var build
            for (var i = 0; i < builds.length; i++) {
                if (builds[i].id === info.last_build_id) {
                    build = builds[i]
                    break
                }
            }

            return build ? build.message : ""
        }
    }

    summary: i18n.tr("Build %1").arg(info.last_build_number)
    summaryValue: buildStatus(info.last_build_result)

    viewAllMessage: "View build history"

    property string repo:  project.serviceValue("travis")

    onRepoChanged: reload()

    function statusColor(status) {
        if (status === 0)
            return "green"
        else if (status === 1)
            return "red"
        else
            return ""
    }

    function buildStatus(status) {
        return "<font color=\"" + statusColor(status) + "\">" + (status === -1 ? i18n.tr("Pending") : status === 0 ? i18n.tr("Passed") : status === 1 ? i18n.tr("Failed") : i18n.tr("Error")) + "</font>"
    }

    function reload() {
        loading += 2
        travisCI.getRepo(repo, function(has_error, status, response) {
            loading--
            if (has_error)
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download results from Travis CI. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            //print("Travis CI Results:", response)
            doc.set("repo", JSON.parse(response))
        })

        travisCI.getBuilds(repo, function(has_error, status, response) {
            loading--
            if (has_error)
                error(i18n.tr("Connection Error"), i18n.tr("Unable to download results from Travis CI. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            //print("Travis CI Results:", response)
            doc.set("builds", JSON.parse(response))
        })
    }

    page: Component {
        id: buildsPage

        PluginPage {
            title: i18n.tr("Build History")

            flickable: listView

            ListView {
                id: listView
                anchors.fill: parent
                model: builds
                delegate: BuildListItem {
                    number: modelData.number
                    message: modelData.message
                    status: modelData.result != null ? modelData.result : -1
                    built_at:  modelData.finished_at != null ? modelData.finished_at : ""
                }
                clip: true
            }

            Scrollbar {
                flickableItem: listView
            }
        }
    }
}
