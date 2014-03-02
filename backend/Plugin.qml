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
import "../components"
import "../ubuntu-ui-extras"

UbuntuShape {
    id: plugin

    color: Qt.rgba(0,0,0,0.2)

    radius: "medium"

    property alias title: titleLabel.text
    property string shortTitle: title
    property alias iconSource: iconImage.name
    property bool unread
    property int loading: 0
    property string viewAllMessage
    property string summary
    property string summaryValue
    property bool expanded: document.get("expanded" + title, true)
    function reload() {}

    property Component page

    signal triggered

    onTriggered: {
        if (page)
            displayPlugin(plugin)
    }

    Connections {
        target: plugin.project
        onReload: {
            print("Reloading" + plugin.title)
            plugin.reload()
        }
    }

    onClicked: document.set("expanded" + title, !expanded)

    //opacity: unread ? 1 : 0.5

    height: titleLabel.height + units.gu(3) + contents.height

    default property alias contents: column.data

    signal clicked()

    property Project project
    property alias action: actionButton.action
    property Document document

    Item {
        id: titleItem
        clip: true
        height: titleLabel.height + units.gu(3)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        UbuntuShape {
            radius: "medium"
            color: Qt.rgba(0,0,0,0.2)
            height: plugin.height

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            MouseArea {
                anchors.fill: parent
                onClicked: plugin.clicked()
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

            ActivityIndicator {
                visible: loading > 0
                running: loading > 0

                anchors {
                    right: parent.right
                    margins: units.gu(1.5)
                    verticalCenter: titleLabel.verticalCenter
                }
            }

            Button {
                id: actionButton
                visible: action && loading == 0
                height: units.gu(4)
                anchors {
                    right: parent.right
                    margins: units.gu(1)
                    verticalCenter: titleLabel.verticalCenter
                }
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

        ListItem.ThinDivider {}

        Column {
            id: column
            width: parent.width
            height: expanded ? childrenRect.height : 0
            clip: true

            Behavior on height {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.SlowDuration
                }
            }
        }

        ListItem.SingleValue {
            text: expanded ? viewAllMessage : summary
            value: expanded ? "" : summaryValue
            progression: true
            showDivider: false
            onTriggered: plugin.triggered()
        }
    }
}
