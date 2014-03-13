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
    type: ["GitHubIssues"]//, "GitHubPullRequests", "GitHub"]
    title: i18n.tr("GitHub")
    authenticationStatus: oauth === "" ? "" : i18n.tr("Logged in as %1").arg(user)
    disabledMessage: i18n.tr("To connect to a GitHub project, please authenticate to GitHub from Settings")

    enabled: oauth !== ""

    property string oauth:settings.get("githubToken", "")
    property string github: "https://api.github.com"
    property string user: settings.get("githubUser", "")

    onOauthChanged: {
        if (oauth !== "") {
            get("/user", userLoaded)
        } else {
            settings.set("githubUser", "")
        }
    }

    function userLoaded(has_error, status, response) {
        //print("User:", response)
        var json = JSON.parse(response)

        if (has_error && json.hasOwnProperty("message") && json.message === "Bad credentials") {
            settings.set("githubToken", "")
            PopupUtils.open(accessRevokedDialog, mainView.pageStack.currentPage)
        } else {
            settings.set("githubUser", json.login)
        }
    }

    function get(request, callback, options) {
        if (oauth === "")
            return undefined
        if (options === undefined)
            options = []
        if (request && request.indexOf(github) !== 0)
            request = github + request
        return Http.get(request, ["access_token=" + oauth].concat(options), callback, undefined, {"Accept":"application/vnd.github.v3+json"})
    }

    function post(request, callback, options, body) {
        if (oauth === "")
            return undefined
        if (options === undefined)
            options = []
        if (request && request.indexOf(github) !== 0)
            request = github + request
        return Http.post(request, ["access_token=" + oauth].concat(options), callback, undefined, {"Accept":"application/vnd.github.v3+json"}, body)
    }

    function getIssues(repo, state, callback) {
        return get("/repos/" + repo + "/issues", callback, ["state=" + state])
    }

    function editIssue(repo, number, issue, callback) {
        return Http.patch(github + "/repos/" + repo + "/issues/" + number, ["access_token=" + oauth], callback, undefined, {"Accept":"application/vnd.github.v3+json"}, JSON.stringify(issue))
    }

    function newIssue(repo, title, description, callback) {
        return Http.post(github + "/repos/" + repo + "/issues", ["access_token=" + oauth], callback, undefined, {"Accept":"application/vnd.github.v3+json"}, JSON.stringify({ "title": title, "body": description }))
    }

    function newPullRequest(repo, title, description, branch, callback) {
        return Http.post(github + "/repos/" + repo + "/pulls", ["access_token=" + oauth], callback, undefined, {"Accept":"application/vnd.github.v3+json"}, JSON.stringify({ "title": title, "body": description, "head": branch, "base": "master" }))
    }

    function getPullRequests(repo, state, callback) {
        return get("/repos/" + repo + "/pulls", callback, ["state=" + state])
    }

    function getPullRequest(repo, number, callback) {
        return get("/repos/" + repo + "/pulls/" + number, callback)
    }

    function getAssignees(repo, callback) {
        return get("/repos/" + repo + "/assignees", callback)
    }

    function getMilestones(repo, callback) {
        return get("/repos/" + repo + "/milestones", callback)
    }

    function getLabels(repo, callback) {
        return get("/repos/" + repo + "/labels", callback)
    }

    function getBranches(repo, callback) {
        return get("/repos/" + repo + "/branches", callback)
    }

    function getRepository(repo, callback) {
        return get("/repos/" + repo, callback)
    }

    function getIssueComments(repo, issue, callback) {
        return get('/repos/' + repo + '/issues/' + issue.number + '/comments', callback)
    }

    function getPullCommits(repo, pull, callback) {
        return get('/repos/' + repo + '/pulls/' + pull.number + '/commits', callback)
    }

    function getIssueEvents(repo, issue, callback) {
        return get('/repos/' + repo + '/issues/' + issue.number + '/events', callback)
    }

    function newIssueComment(repo, issue, comment, callback) {
        return post("/repos/" + repo + "/issues/" + issue.number + "/comments", callback, undefined, JSON.stringify({body: comment}))
    }

    function connect(project) {
        //print("Connecting...")
        PopupUtils.open(githubDialog, mainView.pageStack.currentPage, {project: project})
    }

    function authenticate() {
        pageStack.push(Qt.resolvedUrl("OAuthPage.qml"))
    }

    function revoke() {
        settings.set("githubToken", "")
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

    Component {
        id: accessRevokedDialog

        Dialog {

            title: i18n.tr("GitHub Access Revoked")
            text: i18n.tr("You will no longer be able to access any projects on GitHub. Go to Settings to re-enable GitHub integration.")

            Button {
                text: i18n.tr("Ok")
                onTriggered: {
                    PopupUtils.close(accessRevokedDialog)
                }
            }

            Button {
                text: i18n.tr("Open Settings")
                onTriggered: {
                    PopupUtils.close(accessRevokedDialog)
                    pageStack.push(Qt.resolvedUrl("ui/SettingsPage.qml"))
                }
            }
        }
    }
}
