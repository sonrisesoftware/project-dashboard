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

Page {
    id: page
    
    title: i18n.tr("Settings")

    Column {
        anchors.fill: parent

        ListItem.Header {
            text: i18n.tr("Connected Accounts")
        }

        ListItem.SingleValue {
            Column {
                spacing: units.gu(0.1)

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(1)
                    right: parent.right
                }

                Label {

                    width: parent.width
                    elide: Text.ElideRight
                    text: "GitHub"
                }

                Label {
                    width: parent.width

                    height: visible ? implicitHeight: 0
                    color:  Theme.palette.normal.backgroundText
                    fontSize: "small"
                    //font.italic: true
                    text: github.oauth === "" ? "" : ("Logged in as " + github.user)
                    visible: text !== ""
                    elide: Text.ElideRight
                }
            }
            value: github.oauth !== "" ? github.user : ""
            Button {
                text: github.oauth === "" ? i18n.tr("Log in") : i18n.tr("Log out")
                height: units.gu(4)
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                onClicked: {
                    if (github.oauth === "")
                        pageStack.push(Qt.resolvedUrl("../backend/services/OAuthPage.qml"))
                    else
                        settings.set("githubToken", "")
                }
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }
}
