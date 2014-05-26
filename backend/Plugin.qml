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
import "../components"
import "../ubuntu-ui-extras"
import "../ui/project_page"

Item {
    id: plugin

    property string name
    property string type
    property Project project
    property string configuration

    property string title
    property string icon

    property bool canReload: false
    property bool changed
    function refresh() {}
    function setup() {}

    property Component configView: PluginConfigView {

    }

    onChangedChanged: timer.start()

    function displayMessage(message) {}

    function getPreview(message) {
        //print("Getting preview", plugin)
    }

    function toJSON() { return doc.toJSON() }
    function fromJSON(json) { doc.fromJSON(json) }

    signal save()
    signal loaded()

    property Document doc: Document {

        onSave: plugin.save()
        onLoaded: plugin.loaded()
    }

    property list<PluginItem> items

//    Connections {
//        target: project
//        onReload: {
//            //print("Reloading" + plugin.name)
//            plugin.reload()
//        }
//    }

    Timer {
        id: timer
        interval: 10
        onTriggered: save()
    }
}
