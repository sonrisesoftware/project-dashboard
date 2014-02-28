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

    name: "github"
    type: ["GitHubIssues", "GitHubPullRequests"]
    title: "GitHub"
    docId: 3

    property bool enabled: oauth !== ""

    property string oauth:settings.get("githubToken", "")
    property string github: "https://api.github.com"
    property string user: settings.get("githubUser", "")

    signal accessRevoked

    onOauthChanged: {
        if (oauth !== "") {
            get("/user", userLoaded)
        } else {
            settings.set("githubUser", "")
        }
    }

    function userLoaded(response) {
        print("User:", response)
        var json = JSON.parse(response)

        if (json.hasOwnProperty("message") && json.message === "Bad credentials") {
            settings.set("githubToken", "")
            accessRevoked()
        } else {
            settings.set("githubUser", json.login)
        }
    }

    function get(request, callback) {
        return Http.get(github + request, ["access_token=" + oauth], callback)
    }

    function getIssues(repo, callback) {
        return get("/repos/" + repo + "/issues", callback)
    }

    function newIssue(repo, title, description, callback) {
        return Http.post(github + "/repos/" + repo + "/issues", ["access_token=" + oauth], callback, undefined, JSON.stringify({ "title": title, "description": description }))
    }

    function getPullRequests(repo, callback) {
        return get("/repos/" + repo + "/pulls", callback)
    }

    function connect(project) {
        print("Connecting...")
        PopupUtils.open(githubDialog, mainView.pageStack.currentPage, {project: project})
    }

    function status(value) {
        return i18n.tr("Connected to %1").arg(value)
    }

    Component {
        id: githubDialog

        InputDialog {
            property var project

            title: i18n.tr("Connect to GitHub")
            text: i18n.tr("Enter the name of repository on GitHub you would like to add to your project")
            placeholderText: i18n.tr("owner/repo")
            onAccepted: {
                project.enablePlugin("github", value)
            }
        }
    }
}
