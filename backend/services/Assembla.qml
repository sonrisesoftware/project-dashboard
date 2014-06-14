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

import "../promises.js" as Promise

Service {
    id: root

    name: "assembla"
    icon: "adn"
    type: "Assembla"
    title: i18n.tr("Assembla")
    authenticationStatus: oauth === "" ? "" : i18n.tr("Logged in as %1").arg(user.login)
    disabledMessage: i18n.tr("Authenticate to Assembla in Settings")

    description: i18n.tr("Manage, Deliver, and Maintain Websites, Apps, and Agile Projects.")

    accountItem: ListItem.Subtitled {
        // TODO: Doesn't work, requires authentication
        //iconSource: assembla + "/users/" + user.login + "/picture"
        text: user.name
        subText: user.login
        visible: oauth !== ""
        progression: true
        height: visible ? units.gu(8) : 0
    }

    enabled: oauth !== ""

    property string oauth:settings.get("assemblaToken", "")
    property string assembla: "https://api.assembla.com/v1"
    property var user: settings.get("assemblaUser", "")
    property var repos: settings.get("assemblaRepos", [])

    function isEnabled(project) {
        if (enabled) {
            return ""
        } else {
            return disabledMessage
        }
    }

    onOauthChanged: {
        if (oauth !== "") {
            httpGet('/user.json').done(function(response) {
                var json = JSON.parse(response)
                settings.set("assemblaUser", json)
            })

            httpGet('/spaces.json').done(function(response) {
                var json = JSON.parse(response)
                settings.set("assemblaRepos", json)
            })
        } else {
            settings.set("assemblaUser", undefined)
        }
    }

    function authenticate() {
        pageStack.push(Qt.resolvedUrl("AssemblaOAuth.qml"))
    }

    function revoke() {
        settings.set("assemblaToken", "")
    }

    function httpGet(endpoint, args) {
        var promise = new Promise.Promise()

        Http.get(assembla + expand(endpoint, args), undefined, function(has_error, status, response) {
            if (has_error) {
                promise.reject(status)
            } else {
                promise.resolve(response)
            }
        }, undefined, {"Authorization": "Bearer " + oauth})

        return promise
    }

    function expand(string, args) {
        if (!args)
            return string
        for (var i = 0; i < args.length; i++) {
            string = string.arg(args[i])
        }

        return string
    }
}
