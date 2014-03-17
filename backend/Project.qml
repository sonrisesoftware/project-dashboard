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

    property alias docId: doc.docId

    property string name: doc.get("name", "")
    onNameChanged: name = doc.sync("name", name)

    property alias document: doc

    property var plugins: doc.get("plugins", {"notes": true})

    signal reload

    function enablePlugin(name, value) {
        var beforeValue = hasPlugin(name)

        //print("Setting state of", name, "to:", value)
        plugins[name] = value
        doc.set("plugins", plugins)

        var plugin = backend.getPlugin(name)
        var type = plugin.type

        if (hasPlugin(name) !== beforeValue) {
            if (hasPlugin(name)) {
                if (typeof(type) == "object") {
                    for (var j = 0; j < type.length; j++) {
                        enabledPlugins.append({"type": type[j]})
                    }
                } else {
                    enabledPlugins.append({"type": type})
                }
            } else {
                for (var i = 0; i < enabledPlugins.count; i++) {
                    if ((typeof(type) === "object" && type.indexOf(enabledPlugins.get(i).type)) ||
                         (enabledPlugins.get(i).type === type)) {
                        enabledPlugins.remove(i)
                    }
                }
            }
        }
    }

    property ListModel enabledPlugins: ListModel {

    }

    function hasPlugin(name) {
        return plugins.hasOwnProperty(name) && (plugins[name] === true || (plugins[name] !== false && plugins[name] !== ""))
    }

    function serviceValue(name) {
        return plugins.hasOwnProperty(name) ? plugins[name] : ""
    }

    //property var enabledPlugins: []


    function loadPlugins() {
        var list = []

        var pluginObjects = []
        for (var name in plugins) {
            if (!hasPlugin(name))
                continue
            var plugin = backend.getPlugin(name)
            //print(plugin.name)
            pluginObjects.push(plugin)
        }

        pluginObjects = pluginObjects.sort(function(item1, item2) {
            return item1.name - item2.name
        })

        for (var i = 0; i < pluginObjects.length; i++) {
            plugin = pluginObjects[i]
            var type = plugin.type
            //print("Type:", typeof(type))

            if (typeof(type) == "object") {
                for (var j = 0; j < type.length; j++) {
                    enabledPlugins.append({"type": type[j]})
                }
            } else {
                enabledPlugins.append({"type": type})
            }
        }
    }

    Document {
        id: doc
        parent: backend.document

        Component.onCompleted: loadPlugins()
    }

    function remove() {
        doc.remove()
    }
}
