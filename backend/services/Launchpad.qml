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

    name: "launchpad"
    type: ["LaunchpadBugs"]
    title: i18n.tr("Launchpad")
    docId: 6
    authenticationStatus: oauth === "" ? "" : i18n.tr("Logged in as %1").arg(user)
    disabledMessage: i18n.tr("To connect to a launchpad project, please authenticate to launchpad from Settings")

    enabled: true
    authenticationRequired: false

    property string oauth:settings.get("launchpadToken", "")
    property string launchpad: "https://api.launchpad.net/1.0/"
    property string user: settings.get("launchpadUser", "")

    onOauthChanged: {
        if (oauth !== "") {
            get("/user", userLoaded)
        } else {
            settings.set("launchpadUser", "")
        }
    }

    function userLoaded(has_error, status, response) {
        print("User:", response)
        var json = JSON.parse(response)

        if (has_error && json.hasOwnProperty("message") && json.message === "Bad credentials") {
            settings.set("launchpadToken", "")
            PopupUtils.open(accessRevokedDialog, mainView.pageStack.currentPage)
        } else {
            settings.set("launchpadUser", json.login)
        }
    }

    function get(request, callback, options) {
        //if (oauth === "")
        //    return undefined
        if (options === undefined)
            options = []
        if (request && request.indexOf(launchpad) !== 0)
            request = launchpad + request
        return Http.get(request, options, callback)
    }

    function getRepository(repo, callback) {
        return get(repo, callback)
    }

    function getBugs(repo, callback) {
        return get(repo + '/searchTasks', callback, ['status=New,Incomplete,Triaged,Opinion,Invalid,Won\'t Fix,Confirmed,In Progress,Fix Committed,Fix Released'])
    }

    function connect(project) {
        print("Connecting...")
        PopupUtils.open(launchpadDialog, mainView.pageStack.currentPage, {project: project})
    }

    function authenticate() {
        pageStack.push(Qt.resolvedUrl("OAuthPage.qml"))
    }

    function revoke() {
        settings.set("launchpadToken", "")
    }

    function status(value) {
        return i18n.tr("Connected to %1").arg(value)
    }

    Component {
        id: launchpadDialog

        InputDialog {
            property var project

            title: i18n.tr("Connect to Launchpad")
            text: i18n.tr("Enter the name of project on Launchpad you would like to add to your project")
            placeholderText: i18n.tr("Name")
            onAccepted: {
                project.enablePlugin("launchpad", value)
            }
        }
    }
}
