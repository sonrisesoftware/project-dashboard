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

ListItem.Standard {
    id: listItem

    //property var modelData: plugin.issues[index]
    property bool showAssignee: true

    onClicked: pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {issue: modelData, plugin:plugin})

    height: opacity === 0 ? 0 : (__height + units.dp(2))

    Behavior on height {
        UbuntuNumberAnimation {}
    }

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

            width: parent.width
            elide: Text.ElideRight
            text: i18n.tr("<b>#%1</b> - %2").arg(modelData.number).arg(modelData.title)

            font.strikeout: modelData.state === "closed"
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
            text: {
                var text = i18n.tr("%1 opened this issue %2").arg(modelData.user.login).arg(friendsUtils.createTimeString(modelData.created_at))
                if (modelData.labels.length > 0) {
                    text += " | "
                    for (var i = 0; i < modelData.labels.length; i++) {
                        var label = modelData.labels[i]
                        text += '<font color="#' + label.color + '">' + label.name + '</font>'
                        if (i < modelData.labels.length - 1)
                            text += ', '
                    }
                }

                return text
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
        visible: modelData.assignee !== undefined && modelData.assignee.hasOwnProperty("login") && modelData.assignee !== "" && showAssignee

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
                source: modelData.assignee.avatar_url
            }
        }
    }

    opacity: show ? 1 : 0

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    property bool show: true
}
