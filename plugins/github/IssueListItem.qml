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
import "../../model"
import "../../qml-extras/dateutils.js" as DateUtils
import "../../components"

ListItem.Standard {
    id: listItem

    property int number: issue.number
    property bool showAssignee: true

    property bool isPullRequest: issue.isPullRequest

    property bool showProject: false

    // Property to set the width of the pull request status icon if visible so that the title gets truncated properly.
    property double iconWidth: 0

    onClicked: pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {issue: issue, plugin:plugin})

    height: opacity === 0 ? 0 : (__height + units.dp(2))

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    property Issue issue
    property alias text: titleLabel.text
    property alias subText: subLabel.text

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
            rightMargin: indicators.width > 0 ? units.gu(1) : units.gu(2)
            right: indicators.left
        }

        Label {
            id: titleLabel

            width: issue.isPullRequest ? parent.width - iconWidth : parent.width
            elide: Text.ElideRight
            text: i18n.tr("<b>#%1</b> - %2").arg(issue.number).arg(issue.title)

            font.strikeout: !issue.open
        }

        Label {
            id: subLabel
            width: parent.width

            //height: visible ? implicitHeight: 0
            //color:  Theme.palette.normal.backgroundText
            opacity: 0.65
            font.weight: Font.Light
            fontSize: "small"
            //font.italic: true
            text: {
                if (showProject) {
                    return issue.parent.parent.name
                } else if (issue.isPullRequest) {
                    return i18n.tr("%1 opened this pull request %2").arg(issue.user.login).arg(DateUtils.friendlyTime(issue.created_at))
                } else {
                    return issue.summary
                }
            }
            visible: text !== ""
            elide: Text.ElideRight
        }
    }

    Row {
        id: indicators

        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        spacing: units.gu(1)

        AwesomeIcon {
            size: units.gu(3)
            anchors.verticalCenter: parent.verticalCenter

            name: issue.state === "In Progress" ? "dot-circle-o" : issue.state === "Test" ? "check-circle" : issue.state === "Invalid" ? "ban" : ""
            visible: name !== ""
        }

        Item {
            id: assigneeIndicator

            anchors.verticalCenter: parent.verticalCenter
            width: visible ? units.gu(4) : 0
            height: width
            visible: issue.hasOwnProperty("assignee") && issue.assignee != undefined && issue.assignee.hasOwnProperty("login") && issue.assignee !== "" && showAssignee

            UbuntuShape {
                anchors.fill: parent

                image: Image {
                    source: getIcon("user")
                }
            }

            UbuntuShape {
                visible: image.status === Image.Ready
                anchors.fill: parent

                image: Image {
                    source: assigneeIndicator.visible ? issue.assignee.avatar_url : ""
                }
            }
        }
    }

    opacity: show ? issue.open ? 1 : 0.5 : 0

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    property bool show: true
}
