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

    function toJSON() { return doc.toJSON() }
    function fromJSON(json) { doc.fromJSON(json) }

    property int nextIndex: 0

    Document {
        id: doc

        onSave: {
            // Save projects
            var list = []
            for (var i = 0; i < projects.count; i++) {
                var project = projects.get(i).modelData
                list.push(project.toJSON())
            }

            doc.set("projects", list)
        }

        onLoaded: {
            var list = doc.get("projects", [])
            for (var i = 0; i < list.length; i++) {
                var project = projectComponent.createObject(mainView, {index: nextIndex++})
                project.fromJSON(list[i])
                projects.append({"modelData": project})
            }
        }
    }

    property ListModel projects: ListModel {

    }

    function newProject(name) {
        var project = projectComponent.createObject(mainView, {index: nextIndex++})
        project.name = name
        projects.append({"modelData": project})
        project.fromJSON({})
        return project
    }

    function removeProject(index) {
        for (var i = 0; i < projects.count; i++) {
            var project = projects.get(i).modelData

            if (project.index === index) {
                projects.remove(i)
                project.destroy(1000)
                return
            }
        }
    }

    Component {
        id: projectComponent

        Project {

        }
    }

    property ListModel availablePlugins: ListModel {
//        ListElement {
//            name: "tasks"
//            type: "ToDo"
//            title: "Tasks"
//        }

        ListElement {
            name: "notes"
            type: "Notes"
            title: "Notes"
        }

//        ListElement {
//            name: "drawings"
//            type: ""
//            title: "Drawings"
//        }

        ListElement {
            name: "resources"
            type: "Resources"
            title: "Resources"
        }

        ListElement {
            name: "timer"
            type: "Timer"
            title: "Timer"
        }
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
