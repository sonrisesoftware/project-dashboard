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

ListItem.SingleValue {
    property int number
    property int status
    property string message
    property string built_at

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
        }

        width: parent.width * 0.8

        Label {
            id: titleLabel

            width: parent.width
            elide: Text.ElideRight
            text: status === -1 ? i18n.tr("<b>Build %1</b> - in progress").arg(number) : i18n.tr("<b>Build %1</b> - %2").arg(number).arg(friendsUtils.createTimeString(built_at))
        }

        Label {
            id: subLabel
            width: parent.width

            height: visible ? implicitHeight: 0
            //color:  Theme.palette.normal.backgroundText
            opacity: 0.65
            font.weight: Font.Light
            fontSize: "small"
            //font.italic: true
            text: message.indexOf('\n') === -1 ? message : message.substring(0, message.indexOf('\n'))
            visible: text !== ""
            elide: Text.ElideRight
            //maximumLineCount: 1
        }
    }

    value: buildStatus(status)
}
