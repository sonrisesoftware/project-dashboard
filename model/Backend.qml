import QtQuick 2.0
import "internal" as Internal

Internal.Backend {
    id: backend

    function addProject(name) {
        var project = _db.create('Project', {name: name}, backend)
        projects.add(backend)

        return project
    }

    function importProject(json) {
        var project = addProject(json.name)
    }

    property ListModel availablePlugins: ListModel {

        ListElement {
            icon: "check-square-o"
            name: "tasks"
            type: "ToDo"
            title: "Tasks"
        }

        ListElement {
            icon: "pencil-square-o"
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
            icon: "file"
            name: "resources"
            type: "Resources"
            title: "Resources"
        }

        ListElement {
            icon: "clock"
            name: "timer"
            type: "Timer"
            title: "Time Tracker"
        }

        ListElement {
            icon: "calendar"
            name: "events"
            type: "Events"
            title: "Events"
        }

        ListElement {
            icon: "shopping-cart"
            name: "appstore"
            type: "ClickAppStore"
            title: "Ubuntu App Store"
        }
    }

    property var availableServices: [github]

    function getPlugin(name) {
        for (var i = 0; i < availablePlugins.count;i++) {
            var plugin = availablePlugins.get(i)
            if (plugin.name === name)
                return plugin
        }
    }

    function clearInbox() {
        for (var i = 0; i < projects.count; i++) {
            var project = projects.get(i).modelData
            project.clearInbox()
        }
    }
}
