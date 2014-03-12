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

SubtitledListItem {
    id: listItem

    onClicked: pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {issue: modelData, plugin:plugin})

    text: i18n.tr("<b>#%1</b> - %2").arg(modelData.number).arg(modelData.title)
    subText: i18n.tr("%1 opened this pull request %2").arg(modelData.user.login).arg(friendsUtils.createTimeString(modelData.created_at))

    property string status: modelData.hasOwnProperty("status") ? modelData.status.state : ""

    AwesomeIcon {
        anchors.centerIn: icon

        width: units.gu(2)
        size: status === "pending" ? units.gu(3) : units.gu(2.8)

        color: status === "pending" ? "gray" : "white"
        name: "circle"
        visible: status != "error" && status != ""
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
