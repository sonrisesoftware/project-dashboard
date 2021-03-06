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
import "../model"

import "../qml-extras/listutils.js" as List

Item {
    id: page

    property int count: List.concat(backend.projects, "inbox", function(project) { return project.notificationsEnabled }).length

    ListView {
        id: listView
        anchors.fill: parent
        model: backend.projects
        delegate: Column {
            width: parent.width
            property Project project: modelData

            visible: project.notificationsEnabled

            ListItem.Header {
                text: project.name
                opacity: repeater.count > 0 ? 1 : 0
                visible: opacity > 0

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: units.gu(2)
                    }
                    text: repeater.count
                }

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }
            }

            Repeater {
                id: repeater
                model: project.inbox
                delegate: ListItem.Empty {
                    id: listItem
                    onClicked: project.displayMessage(modelData)

                    removable: true
                    onItemRemoved: project.removeMessage(index)
                    backgroundIndicator: ReadListItemBackground {
                        willRemove: width > (listItem.width * 0.3) && width < listItem.width
                        state: listItem.swipingState
                    }

                    AwesomeIcon {
                        id: icon
                        name: modelData.icon
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
                                text: modelData.title
                            }

                            Label {
                                id: dateLabel
                                font.italic: true
                                text: friendlyTime(new Date(modelData.date))
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
                            text: modelData.message
                            visible: text !== ""
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    Scrollbar {
        flickableItem: listView
    }

    Label {
        opacity: 0.5
        fontSize: "large"
        text: i18n.tr("No unread messages")
        anchors.centerIn: parent

        visible: listView.contentHeight == 0

    }

    function friendlyTime(time) {
        var now = new Date()
        var seconds = (now - time)/1000;
        ////print("Difference:", now, time, now - time)
        var minutes = Math.round(seconds/60);
        if (minutes < 1)
            return i18n.tr("Now")
        else if (minutes == 1)
            return i18n.tr("1 minute ago")
        else if (minutes < 60)
            return i18n.tr("%1 minutes ago").arg(minutes)
        var hours = Math.round(minutes/24);
        if (hours == 1)
            return i18n.tr("1 hour ago")
        else if (hours < 24)
            return i18n.tr("%1 hours ago").arg(hours)
        return Qt.formatDate(time)
    }
}
