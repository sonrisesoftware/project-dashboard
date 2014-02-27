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

Object {
    id: root

    property string oauth:settings.get("githubToken", "")
    property string github: "https://api.github.com"
    property string repo

    function getIssues(callback) {
        return Http.get(github + "/repos/" + repo + "/issues", ["access_token=" + oauth], callback)
    }

    function newIssue(title, description, callback) {
        return Http.post(github + "/repos/" + repo + "/issues", ["access_token=" + oauth], callback, undefined, JSON.stringify({ "title": title, "description": description }))
    }

    function getPullRequests(callback) {
        return Http.get(github + "/repos/" + repo + "/pulls", ["access_token=" + oauth], callback)
    }
}
