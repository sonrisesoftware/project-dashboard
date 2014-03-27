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
import "../../components"

IssueListItem {
    id: listItem

    property string status: issue.status

    AwesomeIcon {
        anchors.centerIn: icon
        anchors.verticalCenterOffset: status === "error" ? units.gu(0.04) : 0
        anchors.horizontalCenterOffset: status === "error" ? units.gu(-0) : 0

        width: units.gu(2)
        size: status === "error" ? units.gu(1.85) : status === "pending" ? units.gu(3) : units.gu(2.8)

        color: status === "pending" ? "gray" : "white"
        name: "circle"
        visible: status != ""
    }

    Rectangle {
        width: units.gu(1)
        height: units.gu(1)
        anchors {
            bottom: icon.bottom
            bottomMargin: units.gu(0.5)
            horizontalCenter: icon.horizontalCenter
        }
    }

    AwesomeIcon {
        id: icon
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        size: status == "pending" ? units.gu(2.5) : units.gu(3)
        visible: status != ""
        color: status == "success" ? colors["green"]
                                   : status == "failure" ? colors["red"]
                                                         : status == "error" ? colors["yellow"] : "white"
        name: status == "success" ? "check-circle"
                                 : status == "failure" ? "times-circle"
                                             : status == "error" ? "exclamation-triangle" : "ellipse-h"
    }
}
