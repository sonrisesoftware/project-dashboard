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
    type: ["TravisCI"]
    title: i18n.tr("Travis CI")
    docId: 4
    authenticationStatus: oauth === "" ? "" : i18n.tr("Logged in as %1").arg(user)
    disabledMessage: i18n.tr("To connect to a Travis CI project, please authenticate to Travis CI from Settings")
    authenticationRequired: false

    enabled: true//oauth !== ""

    property string oauth:settings.get("travisToken", "")
    property string travis: "https://api.travis-ci.org"
    property string user: settings.get("travisUser", "")

    onOauthChanged: {
        if (oauth !== "") {
            get("/user", userLoaded)
        } else {
            settings.set("travisUser", "")
        }
    }

    function userLoaded(response) {
        print("User:", response)
        var json = JSON.parse(response)

        if (json.hasOwnProperty("message") && json.message === "Bad credentials") {
            settings.set("travisToken", "")
            PopupUtils.open(accessRevokedDialog, mainView.pageStack.currentPage)
        } else {
            settings.set("travisUser", json.login)
        }
    }

    function get(request, callback, options) {
        if (options === undefined)
            options = []
        return Http.get(travis + request,options, callback, undefined)
    }

    function getRepo(repo, callback) {
        return get("/repos/" + repo, callback)
    }

    function getBuilds(repo, callback) {
        return get("/repos/" + repo + "/builds", callback)
    }

    function connect(project) {
        print("Connecting...")
        PopupUtils.open(travisDialog, mainView.pageStack.currentPage, {project: project})
    }

    function authenticate() {
        pageStack.push(Qt.resolvedUrl("OAuthPage.qml"))
    }

    function revoke() {
        settings.set("travisToken", "")
    }

    function status(value) {
        return i18n.tr("Connected to %1").arg(value)
    }

    Component {
        id: travisDialog

        InputDialog {
            property var project

            title: i18n.tr("Connect to Travis CI")
            text: i18n.tr("Enter the name of repository on Travis CI you would like to add to your project")
            placeholderText: i18n.tr("owner/repo")
            onAccepted: {
                project.enablePlugin("travis", value)
            }
        }
    }

    Component {
        id: accessRevokedDialog

        Dialog {

            title: i18n.tr("Travis CI Access Revoked")
            text: i18n.tr("You will no longer be able to access any projects on Travis CI. Go to Settings to re-enable Travic CI integration.")

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
