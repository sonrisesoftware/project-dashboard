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
import "../components"

import "../qml-air"
import "../qml-air/ListItems" as ListItem

BackgroundView {
    id: tile

    radius: units.gu(0.5)

    property alias title: titleLabel.text
    property string shortTitle: title
    property alias iconSource: iconImage.name
    property string viewAllMessage
    property string summary: viewAllMessage
    property string summaryValue
    property string value: summaryValue
    property bool expanded: true

    signal triggered

    onClicked: expanded = !expanded

    //opacity: unread ? 1 : 0.5

    height: titleLabel.height + units.gu(3) + contents.height

    default property alias contents: column.data

    signal clicked()

    property Action action

    Item {
        id: titleItem
        clip: true
        height: titleLabel.height + units.gu(3)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        BackgroundView {
            radius: tile.radius
            color: "#eee"
            border.color: Qt.rgba(0,0,0,0.1)
            height: tile.height

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            MouseArea {
                anchors.fill: parent
                onClicked: tile.clicked()
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
                    top: parent.top
                    margins: units.gu(2)
                    topMargin: units.gu(1.5)
                }
                //color: unread ? "#77ddff" : Theme.palette.normal.baseText
            }

            Button {
                id: actionButton
                visible: tile.action && parent.width > units.gu(40)

                anchors {
                    right: parent.right
                    margins: units.gu(1)
                    verticalCenter: titleLabel.verticalCenter
                }

                text: tile.action ? tile.action.name : ""
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

        ListItem.ThinDivider {
            color: theme.primary
            height: 2
        }

        Column {
            id: column
            width: parent.width
            clip: true
        }

        ListItem.SingleValue {
            text: expanded ? viewAllMessage : summary
            value: expanded ? "" : summaryValue
            progression: true
            showDivider: false
            onClicked: tile.triggered()
            height: units.gu(5)
        }
    }

    states: State {
        when: !expanded

        PropertyChanges {
            target: column
            restoreEntryValues: true

            height: 0
        }
    }

    transitions: [
        Transition {
            from: "*"
            to: "*"

            NumberAnimation {
                target: column
                property: "height"

                duration: 500
            }
        }
    ]
}
