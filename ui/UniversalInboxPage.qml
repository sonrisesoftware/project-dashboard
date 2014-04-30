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
import "../backend"
import "../components"

import "../qml-air"
import "../qml-air/ListItems" as ListItem
import "../qml-extras/listutils.js" as List

Page {
    id: page

    title: i18n.tr("Inbox")

    count: List.concat(backend.projects, "inbox").length

    leftWidgets: Button {
        text: i18n.tr("Clear")
        enabled: count > 0
        onClicked: {
            backend.clearInbox()
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: backend.projects
        delegate: Column {
            width: parent.width
            property Project project: modelData

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
                    NumberAnimation { duration: 250; }
                }
            }

            Repeater {
                id: repeater
                model: project.inbox
                delegate: ListItem.BaseListItem {
                    id: listItem
                    onClicked: project.displayMessage(modelData)

//                    removable: true
//                    onItemRemoved: project.removeMessage(index)
//                    backgroundIndicator: ReadListItemBackground {
//                        willRemove: width > (listItem.width * 0.3) && width < listItem.width
//                        state: listItem.swipingState
//                    }

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

    ScrollBar {
        flickableItem: listView
    }

    Label {
        anchors.centerIn: parent
        fontSize: "large"
        opacity: 0.5
        text: i18n.tr("No unread messages")
        visible: listView.contentHeight == 0
    }

    Button {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: listView.contentHeight === 0 ? -height : units.gu(1)

            Behavior on bottomMargin {
                NumberAnimation { duration: 200 }
            }

            margins: units.gu(1)
        }

        text: "Mark all as read"
    }

    function friendlyTime(time) {
        var now = new Date()
        var seconds = (now - time)/1000;
        //print("Difference:", now, time, now - time)
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
