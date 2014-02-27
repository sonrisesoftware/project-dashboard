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
import "../ubuntu-ui-extras"

Object {
    id: project

    property int docId: -1

    property string name: doc.get("name", "")
    onNameChanged: name = doc.sync("name", name)

    property alias document: doc

    property var plugins: doc.get("plugins", {
        "todo": true,
        "notes": false,
        "drawings": false
    })

    property var services: doc.get("services", {
        "github": "",
        "launchpad": ""
    })

    property var pluginDocId: {
        "todo": 0,
        "notes": 1,
        "drawings": 2,
        "githubIssues": 3,
        "githubPullRequests": 4,
        "launchpad": 5
    }

    function enabledPlugin(name, state) {
        if (plugins.hasOwnProperty(name)) {
            plugins[name] = state
            plugins = plugins
            doc.set("plugins", plugins)
        } else {
            services[name] = state
            services = services
            doc.set("services", services)
        }
    }

    property var enabledPlugins: {
        var list = []

        if (services.github) { list.push("GitHubIssues"); list.push("GitHubPullRequests") }
        if (plugins.todo) list.push("ToDo")

        return list
    }

    Document {
        id: doc
        docId: project.docId
        parent: backend.document
    }

    function newPlugin() {doc.newDoc({"name": "TEst"})}
}
