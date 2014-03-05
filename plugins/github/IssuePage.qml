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
import "../../components"

Page {
    id: page
    
    title: i18n.tr("Issue %1").arg(issue.number)

    property var issue
    property var request
    property var plugin
    property var comments: []

    Component.onCompleted: {
        github.getIssueComments(plugin.repo, issue, function(has_error, status, response) {
            comments = JSON.parse(response)
        })
    }

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
                        error(i18n.tr("Connection Error"), i18n.tr("Unable to close issue. Check your connection and/or firewall settings."))
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
            left: parent.left
            right: sidebar.left
            top: parent.top
            bottom: parent.bottom
        }

        contentHeight: column.height + units.gu(4)
        contentWidth: width

        Column {
            id: column
            width: parent.width
            anchors {
                top: parent.top
                margins: units.gu(2)
                left: parent.left
                right: parent.right
            }
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
                    color: issue.state === "open" ? colors["green"] : colors["red"]
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
                text: issue.hasOwnProperty("body") ? renderMarkdown(issue.body, plugin.repo) : ""
                height: Math.min(__internal.linesHeight(15), Math.max(__internal.linesHeight(4), edit.height + textArea.__internal.frameSpacing * 2))
                placeholderText: i18n.tr("No description set.")
                readOnly: true
                textFormat: Text.RichText
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                // FIXME: Hack necessary to get the correct line height
                TextEdit {
                    id: edit
                    visible: false
                    width: parent.width
                    textFormat: Text.RichText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: textArea.text
                    font: textArea.font
                }
            }

            Repeater {
                model: comments
                delegate: CommentArea {
                    author: modelData.user.login
                    text: renderMarkdown(modelData.body)
                    date: modelData.created_at
                }
            }

            TextArea {
                id: commentBox
                width: parent.width
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                property bool show

                height: show ? implicitHeight : 0

                onHeightChanged: {
                    mainFlickable.contentY = mainFlickable.contentHeight - mainFlickable.height
                }

                Behavior on height {
                    UbuntuNumberAnimation {}
                }
            }

            Row {
                spacing: units.gu(1)
                anchors.right: parent.right

                Button {
                    text: i18n.tr("Cancel")
                    color: "gray"

                    opacity: commentBox.show ? 1 : 0

                    onClicked: {
                        commentBox.text = ""
                        commentBox.show = false
                    }

                    Behavior on opacity {
                        UbuntuNumberAnimation {}
                    }
                }

                Button {
                    text: i18n.tr("Comment")
                    onClicked: {
                        if (commentBox.show) {
                            busyDialog.title = i18n.tr("Creating Comment")
                            busyDialog.text = i18n.tr("Creating a new comment for issue <b>%1</b>").arg(issue.number)
                            busyDialog.show()

                            var text = commentBox.text

                            request = github.newIssueComment(plugin.repo, issue, commentBox.text, function(response) {
                                busyDialog.hide()
                                if (response === -1) {
                                    error(i18n.tr("Connection Error"), i18n.tr("Unable to create comment. Check your connection and/or firewall settings."))
                                } else {
                                    comments.push({body: text, user: {login: github.user}, date: new Date().toISOString()})
                                    comments = comments

                                    commentBox.text = ""
                                    commentBox.show = false
                                }
                            })
                        } else {
                            commentBox.show = true
                            commentBox.forceActiveFocus()
                        }
                    }
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
                text: issue.milestone && issue.milestone.hasOwnProperty("number") ? issue.milestone.title : i18n.tr("No milestone")
                visible: !plugin.hasPushAccess
            }

            ListItem.ItemSelector {
                model: plugin.milestones.concat(i18n.tr("No milestone"))
                visible: plugin.hasPushAccess
                selectedIndex: {
                    if (issue.milestone && issue.milestone.hasOwnProperty("number")) {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i].number === issue.milestone.number)
                                return i
                        }
                    } else {
                        return model.length - 1
                    }
                }

                delegate: OptionSelectorDelegate {
                    text: modelData.title
                }

                onSelectedIndexChanged: {
                    var number = undefined
                    if (selectedIndex < model.length - 1) {
                        number = model[selectedIndex].number

                        busyDialog.text = i18n.tr("Setting milestone to <b>%1</b>").arg(model[selectedIndex].title)
                    } else {
                        busyDialog.text = i18n.tr("Removing milestone from the issue")
                    }

                    if (issue.milestone && issue.milestone.hasOwnProperty("number") && issue.milestone.number === number)
                        return

                    if (!(issue.milestone && issue.milestone.hasOwnProperty("number")) && number === undefined)
                        return

                    busyDialog.title = i18n.tr("Changing Milestone")
                    busyDialog.show()

                    request = github.editIssue(plugin.repo, issue.number, {"milestone": number}, function(response) {
                        busyDialog.hide()
                        if (response === -1) {
                            error(i18n.tr("Connection Error"), i18n.tr("Unable to change milestone. Check your connection and/or firewall settings."))
                        } else {
                            issue.milestone = {"number": number}
                            issue = issue
                            plugin.reload()
                        }
                    })
                }
            }

            ListItem.Header {
                text: i18n.tr("Assigned To")
            }

            ListItem.Standard {
                text: issue.assignee && issue.assignee.hasOwnProperty("login") ? issue.assignee.login : i18n.tr("No one assigned")
                visible: !plugin.hasPushAccess
            }

            ListItem.ItemSelector {
                model: plugin.availableAssignees.concat(i18n.tr("No one assigned"))
                visible: plugin.hasPushAccess
                selectedIndex: {
                    if (issue.assignee && issue.assignee.hasOwnProperty("login")) {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i].login === issue.assignee.login)
                                return i
                        }
                    } else {
                        return model.length - 1
                    }
                }

                delegate: OptionSelectorDelegate {
                    text: modelData.login
                }

                onSelectedIndexChanged: {
                    var login = undefined
                    if (selectedIndex < model.length - 1) {
                        login = model[selectedIndex].login

                        busyDialog.text = i18n.tr("Setting assignee to <b>%1</b>").arg(model[selectedIndex].login)
                    } else {
                        busyDialog.text = i18n.tr("Removing assignee from the issue")
                    }

                    if (issue.assignee && issue.assignee.hasOwnProperty("login") && issue.assignee.login === login)
                        return

                    if (!(issue.assignee && issue.assignee.hasOwnProperty("login")) && login === undefined)
                        return

                    busyDialog.title = i18n.tr("Changing Assignee")
                    busyDialog.show()

                    request = github.editIssue(plugin.repo, issue.number, {"assignee": login}, function(response) {
                        busyDialog.hide()
                        if (response === -1) {
                            error(i18n.tr("Connection Error"), i18n.tr("Unable to change assignee. Check your connection and/or firewall settings."))
                        } else {
                            issue.assignee = {"login": login}
                            issue = issue
                            plugin.reload()
                        }
                    })
                }
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
