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

import "../../qml-air"
import "../../qml-air/ListItems" as ListItem

ListItem.Standard {
    id: listItem

    property int number: issue.number
    property bool showAssignee: true

    property bool isPullRequest: issue.isPullRequest

    // Property to set the width of the pull request status icon if visible so that the title gets truncated properly.
    property double iconWidth: 0

    onClicked: pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {issue: issue, plugin:plugin})

    height: opacity === 0 ? 0 : units.gu(5.5)

    Behavior on height {
        NumberAnimation { duration: 200 }
    }

    property Issue issue

    Column {
        id: labels

        spacing: units.gu(0.1)

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(2)
            rightMargin: assigneeIndicator.visible ? units.gu(1) : units.gu(2)
            right: assigneeIndicator.visible ? assigneeIndicator.left : parent.right
        }

        Label {
            id: titleLabel

            width: issue.isPullRequest ? parent.width - iconWidth - units.gu(2) : parent.width
            elide: Text.ElideRight
            text: i18n.tr("<b>#%1</b> - %2").arg(issue.number).arg(issue.title)

            font.strikeout: !issue.open
        }

        Label {
            id: subLabel
            width: parent.width

            color: theme.secondaryColor
            font.weight: Font.Light
            fontSize: "small"
            text: {
                if (issue.isPullRequest) {
                    return i18n.tr("%1 opened this pull request %2").arg(issue.user.login).arg(friendlyTime(issue.created_at))
                } else {
                    var text = i18n.tr("%1 opened this issue %2").arg(issue.user.login).arg(friendlyTime(issue.created_at))
                    if (issue.labels.length > 0) {
                        text += " | "
                        for (var i = 0; i < issue.labels.length; i++) {
                            var label = issue.labels[i]
                            text += '<font color="#' + label.color + '">' + label.name + '</font>'
                            if (i < issue.labels.length - 1)
                                text += ', '
                        }
                    }

                    return text
                }
            }
            visible: text !== ""
            elide: Text.ElideRight
        }
    }

    Item {
        id: assigneeIndicator
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        width: units.gu(4)
        height: width
        visible: issue.hasOwnProperty("assignee") && issue.assignee != undefined && issue.assignee.hasOwnProperty("login") && issue.assignee !== "" && showAssignee

        Icon {
            visible: image.status !== Image.Ready
            name: "user"
            size: units.gu(4)
        }

        CircleImage {
            id: image
            anchors.fill: parent
            visible: image.status === Image.Ready
            source: assigneeIndicator.visible ? issue.assignee.avatar_url : ""

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: height/2
                color: "transparent"
                border.color: "white"
                border.width: 3
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                radius: height/2
                color: "transparent"
                border.color: theme.textColor
            }
        }
    }

    opacity: show ? issue.open ? 1 : 0.5 : 0

    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    property bool show: true

    function friendlyTime(time) {
        var now = new Date()
        var seconds = (now - new Date(time))/1000;
        //print("Difference:", now, new Date(time), now - time)
        var minutes = Math.round(seconds/60);
        if (minutes < 1)
            return i18n.tr("just now")
        else if (minutes == 1)
            return i18n.tr("1 minute ago")
        else if (minutes < 60)
            return i18n.tr("%1 minutes ago").arg(minutes)
        var hours = Math.round(minutes/60);
        if (hours == 1)
            return i18n.tr("1 hour ago")
        else if (hours < 24)
            return i18n.tr("%1 hours ago").arg(hours)

        var days = Math.round(hours/24);
        if (days == 1)
            return i18n.tr("1 day ago")
        else if (days < 7)
            return i18n.tr("%1 days ago").arg(days)

        var weeks = Math.round(days/7);
        if (days == 1)
            return i18n.tr("1 week ago")
        else if (days < 24)
            return i18n.tr("%1 weeks ago").arg(days)

        var months = Math.round(weeks/4);
        if (months == 1)
            return i18n.tr("1 month ago")
        else
            return i18n.tr("%1 months ago").arg(months)
    }
}
