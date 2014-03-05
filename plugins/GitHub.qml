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

    title: "GitHub"
    iconSource: "github"
    canReload: true

    property var milestones: doc.get("milestones", [])
    property var info: doc.get("repo", {})
    property var availableAssignees: doc.get("assignees", [])
    property var releases: doc.get("releases", [])
    property var commitStats: doc.get("commit_stats", {})

    document: Document {
        id: doc
        docId: "github"
        parent: project.document
    }

    ListItem.Standard {
        text: i18n.tr("<b>%1</b> commit during the past week",
                      "<b>%1</b> commits during the past week",
                      commitStats["all"][commitStats["all"].length - 1]).arg(commitStats["all"][commitStats["all"].length - 1])
    }

    ListItem.Standard {
        text: i18n.tr("<b>%1</b> contributor",
                      "<b>%1</b> contributors",
                      availableAssignees.length).arg(availableAssignees.length)
    }

    ListItem.Standard {
        text: milestones.length > 0 ? i18n.tr("<b>%1</b> open milestone",
                                              "<b>%1</b> open milestones",
                                              milestones.length).arg(milestones.length)
                                  : i18n.tr("No open milestones")
    }

    ListItem.Standard {
        text: releases.length > 0 ? i18n.tr("<b>%1</b> release",
                                            "<b>%1</b> releases",
                                            releases.length).arg(releases.length)
                                  : i18n.tr("No releases yet")
    }

    viewAllMessage: i18n.tr("Manage project")

    property string repo:  project.serviceValue("github")
    property bool hasPushAccess: info.hasOwnProperty("permissions") ? info.permissions.push : false

    onRepoChanged: reload()

    function reload() {
        loading += 5
        github.getMilestones(repo, function(has_error, status, response) {
            loading--
            //print("Milestones:", response)
            var json = JSON.parse(response)

            doc.set("milestones", json)
        })

        github.getRepository(repo, function(has_error, status, response) {
            loading--
            //print("Repository:", response)
            var json = JSON.parse(response)

            doc.set("repo", json)
        })

        github.getAssignees(repo, function(has_error, status, response) {
            loading--
            print("Repository:", response)
            var json = JSON.parse(response)

            doc.set("assignees", json)
        })

        github.getLabels(repo, function(has_error, status, response) {
            loading--
            print("Labels:", response)
            var json = JSON.parse(response)

            doc.set("labels", json)
        })

        github.get("/repos/" + repo + "/releases", function(has_error, status, response) {
            loading--
            doc.set("releases", JSON.parse(response))
        })

        github.get("/repos/" + repo + "/stats/participation", function(has_error, status, response) {
            loading--
            doc.set("commit_stats", JSON.parse(response))
        })
    }
}
