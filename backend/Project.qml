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
import "../qml-extras"

Item {
    id: project

    property string name: doc.get("name", "")
    property int index

    function toJSON() { return doc.toJSON() }
    function fromJSON(json) { doc.fromJSON(json) }

    property int selectedTab: doc.get("selectedTab", 1)

    property bool loadedSuccessfully: false

    property int loading

    property int maxRecent: wideAspect ? 4 : 3

    property SyncQueue syncQueue: SyncQueue {}

    Document {
        id: doc

        onSave: {
            doc.set("name", name)
            doc.set("selectedTab", selectedTab)

            if (!loadedSuccessfully)
                print("WARNING: Not saving project because it wasn't loaded succesfully!")

            // Save messages
            var inboxList = []
            for (var i = 0; i < inbox.count; i++) {
                var item = inbox.get(i).modelData
                inboxList.push(item)
            }
            doc.set("inbox", inboxList)

            // Save plugins
            var pluginList = []
            for (i = 0; i < plugins.count; i++) {
                var plugin = plugins.get(i).modelData
                var json = plugin.toJSON()
                json.type = plugin.type
                pluginList.push(json)
            }
            doc.set("plugins", pluginList)
        }

        onLoaded: {
            // Load inbox
            var inboxList = doc.get("inbox", [])
            for (var i = 0; i < inboxList.length; i++) {
                var item = inboxList[i]
                inbox.append({"modelData": item})
            }

            // Load plugins
            var pluginList = doc.get("plugins", [])
            for (i = 0; i < pluginList.length; i++) {
                var plugin = newObject(Qt.resolvedUrl("../plugins/" + pluginList[i].type + ".qml"))
                plugin.project = project
                plugin.type = pluginList[i].type
                plugin.fromJSON(pluginList[i])
                plugins.append({"modelData": plugin})
            }

            //TODO: Remove once the config page works!
//            if (plugins.count === 0) {
//                print("Adding first plugin!")
//                addPlugin("Resources")
//            }

            loadedSuccessfully = true
        }
    }

    function newObject(type, args) {
        if (!args)
            args = {}
        print(type)
        var component = Qt.createComponent(type);

        if (component.errorString()) {
            print(component.errorString())
        }

        return component.createObject(project, args);
    }

    function remove() {
        backend.removeProject(index)
    }

    property ListModel inbox: ListModel {

    }

    function refresh() {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i).modelData
            plugin.refresh()
        }
    }

    function clearInbox() {
        inbox.clear()
    }

    function newMessage(plugin, icon, title, message, date, data) {
        inbox.append({
                         "modelData": {
                             "plugin": plugin,
                             "icon": icon,
                             "title": title,
                             "message": message,
                             "date": date,
                             "data": data
                         }
                     })
    }

    function removeMessage(id) {
        inbox.remove(id)
    }

    function displayMessage(message) {
        var name = message.plugin
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i).modelData
            if (plugin.name === name) {
                plugin.displayMessage(message)
                return
            }
        }
    }

    property ListModel plugins: ListModel {

    }

    function addPlugin(type) {
        if (hasPlugin(type))
            return

        var plugin = newObject(Qt.resolvedUrl("../plugins/" + type + ".qml"))
        plugin.type = type
        plugin.project = project
        plugins.append({"modelData": plugin})
        plugin.setup()
    }

    function hasPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i).modelData
            if (plugin.type === type)
                return true
        }

        return false
    }

    function getPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i).modelData
            if (plugin.type === type)
                return plugin
        }

        return null
    }

    function enablePlugin(type, enabled) {
        if (enabled)
            addPlugin(type)
        else
            removePlugin(type)
    }

    function removePlugin(type) {
        print("Removing", type)
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i).modelData
            if (plugin.type === type)
                plugins.remove(i)
        }
    }


    Timer {
        interval: 2 * 60 * 1000 // 2 minutes
        running: true
        repeat: true
        onTriggered: refresh()
    }
}
