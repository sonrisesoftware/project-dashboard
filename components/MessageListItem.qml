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

import "../backend"
import "../ubuntu-ui-extras/dateutils.js" as DateUtils

ListItem.Empty {
    id: listItem

    property Project project
    property var message

    onClicked: listView.message = modelData
    selected: listView.message === modelData

    removable: true
    onItemRemoved: project.removeMessage(index)
    backgroundIndicator: ReadListItemBackground {
        willRemove: width > (listItem.width * 0.3) && width < listItem.width
        state: listItem.swipingState
    }

    AwesomeIcon {
        id: icon
        name: message.icon
        size: units.gu(3.5)
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(1.5)
        }
    }

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: icon.right
            leftMargin: units.gu(1.5)
            rightMargin: units.gu(2)
            right: parent.right
        }

        Item {
            width: parent.width
            height: childrenRect.height
            Label {
                id: titleLabel

                width: parent.width - dateLabel.width - units.gu(1)
                elide: Text.ElideRight
                text: message.title
            }

            Label {
                id: dateLabel
                font.italic: true
                text: DateUtils.friendlyTime(new Date(modelData.date))
                anchors.right: parent.right
            }
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            //color:  Theme.palette.normal.backgroundText
            maximumLineCount: 1
            opacity: 0.65
            font.weight: Font.Light
            fontSize: "small"
            text: message.message
            visible: text !== ""
            elide: Text.ElideRight
        }
    }
}
