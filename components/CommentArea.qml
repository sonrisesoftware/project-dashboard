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

UbuntuShape {
    id: comment
    color: Theme.palette.normal.field//Qt.rgba(0,0,0,0.2)
    width: parent.width
    height: childrenRect.height

    property var event

    property string author: type === "comment" ? event.user.login : event.actor.login
    property string date: event.created_at
    property string text: event.hasOwnProperty("body") ? renderMarkdown(event.body)
                                                       : ""
    property string type: event.hasOwnProperty("event") ? event.event : "comment"

    property string title: i18n.tr("<b>%1</b> commented %2").arg(author).arg(friendsUtils.createTimeString(date))

    Item {
        id: titleItem
        height: label.height + units.gu(2)
        width: parent.width
        clip: true

        UbuntuShape {
            color: Qt.rgba(0,0,0,0.2)
            height: comment.height
            width: parent.width
        }

        Label {
            id: label
            text: title
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: units.gu(1)
            }
        }

        Label {
            text: owner ? i18n.tr("Owner")
                        : contributor ? i18n.tr("Contributor") : ""
            visible: owner || contributor
            font.italic: true
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: units.gu(1)
            }

            property bool owner: repository.repo ? repository.repo.owner.login === author : false
            property bool contributor: {
                for (var i = 0; i < repository.availableAssignees.length; i++) {
                    if (repository.availableAssignees[i].login === author)
                        return true
                }

                return false
            }
        }
    }

    ListItem.ThinDivider {
        id: divider
        anchors.top: titleItem.bottom
        visible: event.hasOwnProperty("body")
    }

    Item {
        id: commentArea
        anchors.top: divider.bottom
        width: parent.width
        height: event.hasOwnProperty("body") ? contents.implicitHeight + units.gu(2.1) : 0

        Label {
            id: contents
            anchors.fill: parent
            anchors.margins: units.gu(1)
            text: comment.text
            textFormat: Text.RichText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }
        }
    }
}
