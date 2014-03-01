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
import "services"

Object {
    id: root

    property alias projects: doc.children

    property alias document: doc

    Document {
        id: doc
        docId: 0
        parent: db.document
        name: "backend storage"
    }

    function newProject(name) {
        doc.newDoc({"name": name})
    }

    property ListModel availablePlugins: ListModel {
        ListElement {
            name: "tasks"
            type: "ToDo"
            title: "Tasks"
            docId: 0
        }

        ListElement {
            name: "notes"
            type: ""
            title: "Notes"
            docId: 1
        }

        ListElement {
            name: "drawings"
            type: ""
            title: "Drawings"
            docId: 2
        }
    }

    GitHub {
        id: github
    }

    TravisCI {
        id: travisCI
    }

    property var availableServices: [github, travisCI]

    function getPlugin(name) {
        for (var i = 0; i < availablePlugins.count;i++) {
            var plugin = availablePlugins.get(i)
            if (plugin.name === name)
                return plugin
        }

        for (i = 0; i < availableServices.length;i++) {
            var service = availableServices[i]
            if (service.name === name)
                return service
        }
    }
}
