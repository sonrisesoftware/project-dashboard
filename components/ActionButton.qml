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

import QtGraphicalEffects 1.0

Item {
    id: button

    width: height
    height: units.gu(5)

    property alias iconName: _icon.name
    signal clicked(var caller)

    property color color: colors["red"]

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            button.clicked(button)
        }
    }

    RectangularGlow {
        id: glowEffect

        opacity: 0.3
        anchors.fill: parent
        glowRadius: width/2
        //cornerRadius: 0
        color: "black"
    }

    Rectangle {
        anchors.fill: parent
        radius: width/2

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        anchors {
            centerIn: parent
        }

        color: _mouseArea.containsMouse ? Qt.darker(button.color, 1.3): button.color//"#d9534f"

        Behavior on color {
            ColorAnimation { duration: UbuntuAnimation.FastDuration }
        }

        border.color: Qt.darker(color, 2)
    }

    AwesomeIcon {
        id: _icon
        size: parent.height * 2/5
        anchors.centerIn: parent
    }
}
