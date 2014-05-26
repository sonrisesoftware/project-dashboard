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

UbuntuShape {
    id: tile

    color: Qt.rgba(0,0,0,0.25) // 0.2

    radius: "medium"

    property alias title: titleLabel.text
    property string shortTitle: title
    property alias iconSource: iconImage.name
    property string viewAllMessage
    property string summary: viewAllMessage
    property string summaryValue
    property string value: summaryValue

    signal triggered

    //opacity: unread ? 1 : 0.5

    height: visible ? titleItem.height + contents.height : 0

    default property alias contents: column.data

    property Action action

    Item {
        id: titleItem
        clip: true
        height: titleLabel.height + (wideAspect ? units.gu(3) : units.gu(3))
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        UbuntuShape {
            radius: "medium"
            color: Qt.rgba(0,0,0,0.3) //0.2
            height: tile.height

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            AwesomeIcon {
                id: iconImage
                anchors {
                    left: parent.left
                    verticalCenter: titleLabel.verticalCenter
                    verticalCenterOffset: units.gu(0.1)
                    leftMargin: units.gu(2)
                }

                size: units.gu(3)
                color: titleLabel.color
            }

            Label {
                id: titleLabel

                fontSize: "large"

                anchors {
                    left: iconImage.right
                    right: parent.right
                    margins: units.gu(2)
                    top: parent.top
                    topMargin: (titleItem.height - titleLabel.height)/2
                }
                //color: unread ? "#77ddff" : Theme.palette.normal.baseText
            }

            Button {
                id: actionButton
                visible: tile.action && wideAspect
                height: units.gu(4)
                anchors {
                    right: parent.right
                    margins: units.gu(1)
                    verticalCenter: titleLabel.verticalCenter
                }

                text: tile.action ? tile.action.text : ""
                onClicked: tile.action.triggered(actionButton)
            }
        }
    }

    Column {
        id: contents

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Rectangle {
            width: parent.width
            height: units.dp(1)

            color: UbuntuColors.orange
        }

        Column {
            id: column
            width: parent.width
            clip: true
        }

        ListItem.Standard {
            text: viewAllMessage
            progression: true
            showDivider: false
            onTriggered: tile.triggered()
        }
    }
}
