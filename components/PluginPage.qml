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

import "../qml-air"

Page {
    id: page

    property list<Action> actions

    rightWidgets: [
        Repeater {
            id: repeater
            model: page.actions
            delegate: Button {
                text: modelData.name
                iconName: modelData.icon
                onClicked: modelData.triggered()
            }
        },

        Button {
            iconName: syncError || noConnection ? "exclamation-triangle" : "spinner-rotate"
            iconColor: noConnection ? theme.warning : syncError ? theme.danger : textColor
            text: noConnection ? "No connection" : syncError ? "Sync error" : "Syncing..."
            opacity: busy || syncError || noConnection ? 1 : 0

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            onClicked: if (!noConnection) syncPopover.open(caller)
        }
    ]

//    default property alias contents: content.children

//    Item {
//        id: content

//        anchors {
//            left: parent.left
//            right: parent.right
//            top: parent.top
//            bottom: toolbar.top
//        }
//    }

//    ToolBar {
//        id: toolbar

//        height: repeater.count > 0 ? implicitHeight : 0

//        Repeater {
//            id: repeater
//            model: page.actions
//            delegate: Button {
//                text: modelData.name
//                iconName: modelData.icon
//                onClicked: modelData.triggered()
//            }
//        }
//    }
}
