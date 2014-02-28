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
import "../../ubuntu-ui-extras"

Page {
    id: page
    
    title: i18n.tr("Issue %1").arg(issue.number)

    property var issue
    property var request
    property var plugin

    actions: [
        Action {
            id: editAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
        },

        Action {
            id: closeAction
            text: i18n.tr("Close")
            iconSource: getIcon("close")
            onTriggered: {
                busyDialog.title = i18n.tr("Closing Issue <b>#%1</b>").arg(issue.number)
                busyDialog.show()

                request = github.editIssue(plugin.repo, issue.number, {"state": "closed"}, function(response) {
                    busyDialog.hide()
                    if (response === -1) {
                        error(i18n.tr("Connection Error"), i18n.tr("Unable to download list of issues. Check your connection and/or firewall settings."))
                    } else {
                        issue.state = "closed"
                        issue = issue
                        plugin.reload()
                    }
                })
            }
        }
    ]

    flickable: sidebar.expanded ? null : mainFlickable

    Flickable {
        id: mainFlickable
        clip: true
        anchors {
            margins: units.gu(2)
            left: parent.left
            right: sidebar.left
            top: parent.top
            bottom: parent.bottom
        }

        contentHeight: column.height
        contentWidth: width

        Column {
            id: column
            width: parent.width
            spacing: units.gu(1)
            Label {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: issue.title
                fontSize: "large"
            }

            Row {
                spacing: units.gu(1)
                UbuntuShape {
                    height: stateLabel.height + units.gu(1)
                    width: stateLabel.width + units.gu(2)
                    color: issue.state === "open" ? "green" : "red"
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: stateLabel
                        anchors.centerIn: parent
                        text: issue.state === "open" ? i18n.tr("Open") : i18n.tr("Closed")
                    }
                }

                Label {
                    text: i18n.tr("<b>%1</b> opened this issue %2").arg(issue.user.login).arg(friendsUtils.createTimeString(issue.created_at))
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextArea {
                id: textArea
                width: parent.width
                text: issue.hasOwnProperty("body") ? renderMarkdown(issue.body) : ""
                height: __internal.linesHeight(Math.min(15, Math.max(4, edit.lineCount)))
                placeholderText: i18n.tr("No description set.")
                readOnly: true
                textFormat: Text.RichText
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                // FIXME: Hack necessary to get the correct line height
                Label {
                    id: edit
                    visible: false
                    width: parent.width
                    //textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: issue.hasOwnProperty("body") ? issue.body : ""//textArea.text
                    font: textArea.font
                }
            }
        }
    }

    Sidebar {
        id: sidebar
        mode: "right"
        expanded: wideAspect

        Column {
            width: parent.width
            ListItem.Header {
                text: i18n.tr("Labels")
            }

            Repeater {
                model: issue.labels
                delegate: ListItem.Standard {
                    Label {
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.name
                        color: "#" + modelData.color
                    }
                }
            }

            ListItem.Standard {
                enabled: false
                text: i18n.tr("None yet")
                visible: issue.labels.length === 0
            }

            ListItem.Header {
                text: i18n.tr("Milestone")
            }

            ListItem.Standard {
                text: enabled ? issue.milestone.title : i18n.tr("No milestone")
                enabled: issue.milestone && issue.milestone.hasOwnProperty("title")
            }

            ListItem.Header {
                text: i18n.tr("Assigned To")
            }

            ListItem.Standard {
                text: enabled ? issue.assignee.login : i18n.tr("No one assigned")
                enabled: issue.assignee && issue.assignee.hasOwnProperty("login")
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        ToolbarButton { action: editAction }
        ToolbarButton { action: closeAction }
    }

    Dialog {
        id: busyDialog

        ActivityIndicator {
            running: busyDialog.visible
            implicitHeight: units.gu(5)
            implicitWidth: implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: i18n.tr("Cancel")
            onTriggered: {
                request.abort()
                busyDialog.hide()
            }
        }
    }
}
