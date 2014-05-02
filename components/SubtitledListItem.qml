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
import "../qml-air/ListItems" as ListItem

ListItem.Standard {
    id: listItem

    property alias text: titleLabel.text
    property alias subText: subLabel.text

    property bool overlay: false

    height: opacity === 0 ? 0 : units.gu(5)

    Behavior on height {
        NumberAnimation {
            duration: 200
        }
    }

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
            right: parent.right
        }

        Label {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight
            maximumLineCount: 1
            color: theme.textColor
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            //color:  Theme.palette.normal.backgroundText
            maximumLineCount: 1
            opacity: overlay ? 0.7 : 0.65
            font.weight: Font.Light
            fontSize: "small"
            visible: text !== ""
            elide: Text.ElideRight
            color: theme.secondaryColor
        }
    }

    opacity: show ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 200
        }
    }

    property bool show: true
}
