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
import "../../ubuntu-ui-extras/httplib.js" as Http
import "../../ubuntu-ui-extras"
import ".."

Service {
    id: root

    name: "travis"
    type: "TravisCI"
    title: i18n.tr("Travis CI")
    disabledMessage: i18n.tr("Requires a GitHub project")
    authenticationRequired: false

    property string travis: "https://api.travis-ci.org"

    function isEnabled(project) {
        if (project.hasPlugin("GitHub")) {
            return ""
        } else {
            return disabledMessage
        }
    }

    function get(project, id, request, callback, options) {
        if (options === undefined)
            options = []
        // httpGet(path, options, headers, callback, args) {
        return project.syncQueue.httpGet(id, travis + request,options, {}, callback)
    }

    function getRepo(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo, callback)
    }

    function getBuilds(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo + "/builds", callback)
    }

    function getBuild(project, id, repo, build, callback) {
        return get(project, id, "/repos/" + repo + "/builds/" + build, callback)
    }

    function getLog(project, id, job, callback) {
        return get(project, id, "/jobs/" + job + "/log", callback)
    }
}
