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

ListItem.Standard {
    id: listItem

    //property var modelData: plugin.issues[index]

    onClicked: pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {issue: modelData, plugin:plugin})

    height: opacity === 0 ? 0 : implicitHeight

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    Label {
        id: titleLabel

        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: units.gu(2)
        }

        elide: Text.ElideRight
        text: i18n.tr("<b>#%1</b> - %2").arg(modelData.number).arg(modelData.title)

        font.strikeout: modelData.state === "closed"
        //font.bold: task.priority !== "low"
        //color: selected ? UbuntuColors.orange : /*task.priority === "low" ? */Theme.palette.selected.backgroundText/* : priorityColor(task.priority)*/
        fontSize: "medium"
    }

    opacity: show ? 1 : 0

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    property bool show: true
}
