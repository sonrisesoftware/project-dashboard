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

import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem

import "../../qml-extras/httplib.js" as Http

import "../../ubuntu-ui-extras"
import ".."

Service {
    id: root

    name: "github"
    icon: "github"
    type: "GitHub"
    title: i18n.tr("GitHub")
    authenticationStatus: oauth === "" ? "" : i18n.tr("Logged in as %1").arg(user.login)
    disabledMessage: i18n.tr("Authenticate to GitHub in Settings")

    description: i18n.tr("GitHub is the best place to share code with friends, co-workers, classmates, and complete strangers. Over six million people use GitHub to build amazing things together.")

    accountItem: ListItem.Subtitled {
        iconSource: user.avatar_url
        text: user.name
        subText: user.login
        visible: oauth !== ""
        progression: true
        height: visible ? units.gu(8) : 0
    }

    enabled: oauth !== ""

    property string oauth:settings.get("githubToken", "")
    property string github: "https://api.github.com"
    property var user: settings.get("githubUser", "")
    property var repos: settings.get("githubRepos", [])

    function isEnabled(project) {
        if (enabled) {
            return ""
        } else {
            return disabledMessage
        }
    }

    onOauthChanged: {
        if (oauth !== "") {
            //get(path, options, callback, args, headers) {
            Http.get(github + "/user", ["access_token=" + oauth], userLoaded,
                     undefined, {"Accept":"application/vnd.github.v3+json"})

            Http.get(github + "/user/repos", ["access_token=" + oauth], function(has_error, status, response) {
                //print("REPOS", response)
                if (status !== 304)
                    settings.set("githubRepos", JSON.parse(response))
            }, undefined, {"Accept":"application/vnd.github.v3+json"})
        } else {
            settings.set("githubUser", undefined)
        }
    }

    function userLoaded(has_error, status, response) {
        var json = JSON.parse(response)
        settings.set("githubUser", json)
    }

    function get(project, id, request, callback, options) {
        ////print("OAuth", oauth)
        if (oauth === "")
            return undefined
        if (options === undefined)
            options = []
        if (request && request.indexOf(github) !== 0)
            request = github + request
        project.syncQueue.httpGet(id, request,["access_token=" + oauth].concat(options), {"Accept":"application/vnd.github.v3+json"}, callback, undefined)
    }

    function post(project, id, request, options, body, message) {
        ////print("OAuth", oauth)
        if (oauth === "")
            return undefined
        if (options === undefined)
            options = []
        if (request && request.indexOf(github) !== 0)
            request = github + request
        project.syncQueue.http(id, "POST", request, ["access_token=" + oauth].concat(options), {"Accept":"application/vnd.github.v3+json"}, body, message)
    }

    function put(project, id, request, options, body, message) {
        ////print("OAuth", oauth)
        if (oauth === "")
            return undefined
        if (options === undefined)
            options = []
        if (request && request.indexOf(github) !== 0)
            request = github + request
        project.syncQueue.http(id, "PUT", request, ["access_token=" + oauth].concat(options), {"Accept":"application/vnd.github.v3+json"}, body, message)
    }

    function getEvents(project, id, repo, callback) {
        get(project, id, "/repos/" + repo + "/events", callback)
    }

    function getIssues(project, id, repo, state, since,callback) {
        return get(project, id, "/repos/" + repo + "/issues", callback, ["state=" + state, "since=" + since])
    }

    function editIssue(project, repo, number, issue, message) {
        var id = project.syncQueue.newGroup(message)
        post(project, id, "/repos/" + repo + "/issues/" + number, undefined, JSON.stringify(issue), i18n.tr("Update issue <b>%1</b>").arg(number))
    }

    function newIssue(project, repo, number, title, description, message) {
        var id = project.syncQueue.newGroup(i18n.tr("Creating pull request <b>%1</b>").arg(number))
        return post(project, id, "/repos/" + repo + "/issues", undefined, JSON.stringify({ "title": title, "body": description }), i18n.tr("Create issue <b>%1</b>").arg(title))
    }

    function newPullRequest(project, repo, number, title, description, branch) {
        var id = project.syncQueue.newGroup(i18n.tr("Creating pull request <b>%1</b>").arg(number))
        return post(project, id, "/repos/" + repo + "/pulls", undefined, JSON.stringify({ "title": title, "body": description, "head": branch, "base": "master" }), i18n.tr("Create pull request <b>%1</b>").arg(title))
    }

    function mergePullRequest(project, repo, number, message) {
        var id = project.syncQueue.newGroup(i18n.tr("Merging pull request <b>%1</b>").arg(number))
        put(project, id, "/repos/" + repo + "/pulls/" + number + "/merge", undefined, JSON.stringify({ "commit_message": message }), i18n.tr("Merge pull request <b>%1</b>").arg(number))
    }

    function getPullRequests(project, id, repo, state, since, callback) {
        return get(project, id, "/repos/" + repo + "/pulls", callback, ["state=" + state, "since=" + since])
    }

    function getPullRequest(project, id, repo, number, callback) {
        return get(project, id, "/repos/" + repo + "/pulls/" + number, callback)
    }

    function getAssignees(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo + "/assignees", callback)
    }

    function getMilestones(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo + "/milestones", callback)
    }

    function getLabels(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo + "/labels", callback)
    }

    function getBranches(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo + "/branches", callback)
    }

    function getRepository(project, id, repo, callback) {
        return get(project, id, "/repos/" + repo, callback)
    }

    function getIssueComments(project, id, repo, issue, callback) {
        return get(project, id, '/repos/' + repo + '/issues/' + issue.number + '/comments', callback)
    }

    function getPullCommits(project, id, repo, pull, callback) {
        return get(project, id, '/repos/' + repo + '/pulls/' + pull.number + '/commits', callback)
    }

    function getIssueEvents(project, id, repo, issue, callback) {
        return get(project, id, '/repos/' + repo + '/issues/' + issue.number + '/events', callback)
    }

    function newIssueComment(project, repo, issue, comment) {
        var id = project.syncQueue.newGroup(i18n.tr("Commenting on issue <b>%1</b>").arg(issue))
        post(project, id, "/repos/" + repo + "/issues/" + issue.number + "/comments", undefined, JSON.stringify({body: comment}), i18n.tr("Comment on issue <b>%1</b>").arg(issue.number))
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
