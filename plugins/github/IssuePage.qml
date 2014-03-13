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
import "../../backend/utils.js" as Utils
import "../../backend/"

Page {
    id: page
    
    title: i18n.tr("%2 %1").arg(issue.number).arg(typeTitle)

    property string type: issue.isPullRequest ? "pull request" : "issue"
    property string typeCap: issue.isPullRequest ? "Pull request" : "Issue"
    property string typeTitle: issue.isPullRequest ? "Pull Request" : "Issue"

    property alias number: issue.number
    property Plugin plugin
    property var request

    Issue {
        id: issue

        Component.onCompleted: load()

        onBusy: {
            busyDialog.title = title
            busyDialog.text = message
            page.request = request

            busyDialog.show()
        }

        onComplete: {
            busyDialog.hide()
        }

        //onError: error(title, message)
    }

    actions: [
        Action {
            id: editAction
            text: i18n.tr("Edit")
            iconSource: getIcon("edit")
            enabled: false
        },

        Action {
            id: mergeAction
            text: i18n.tr("Merge")
            iconSource: getIcon("code-fork")
            enabled: issue.isPullRequest && !issue.merged && issue.mergeable
        },

        Action {
            id: closeAction
            text: issue.open ? i18n.tr("Close") : i18n.tr("Reopen")
            iconSource: issue.open ? getIcon("close") : getIcon("reset")
            enabled: !issue.merged
            onTriggered: {
                closeOrReopen()
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
                    color: issue.merged ? colors["blue"] : issue.open ? colors["green"] : colors["red"]
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: stateLabel
                        anchors.centerIn: parent
                        text: issue.merged ? i18n.tr("Merged") : issue.open ? i18n.tr("Open") : i18n.tr("Closed")
                    }
                }

                Label {
                    text: issue.isPullRequest ? issue.merged ? i18n.tr("<b>%1</b> merged %2 commits").arg(issue.user.login).arg(commits.length)
                                                 : i18n.tr("<b>%1</b> wants to merge %2 commits").arg(issue.user.login).arg(commits.length)
                                        : i18n.tr("<b>%1</b> opened this issue %2").arg(issue.user.login).arg(friendsUtils.createTimeString(issue.created_at))
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

            Column {
                id: eventColumn
                width: parent.width
                spacing: parent.spacing

                Repeater {
                    model: issue.allEvents
                    delegate: EventItem {
                        id: eventItem
                        event: modelData
                        last: eventItem.y + eventItem.height == eventColumn.height
                    }
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

            Item {
                width: parent.width
                height: childrenRect.height

                ActivityIndicator {
                    id: eventLoadingIndicator
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    visible: issue.loading > 0
                    running: visible
                }

                Label {
                    text: "Loading events..."
                    anchors {
                        left: eventLoadingIndicator.right
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    visible: eventLoadingIndicator.visible
                }

                Row {
                    spacing: units.gu(1)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

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
                        text:  issue.state === "open" ? i18n.tr("Comment and Close") : i18n.tr("Comment and Reopen")
                        color: issue.state === "open" ? colors["red"] : colors["green"]

                        opacity: commentBox.show ? 1 : 0
                        enabled: commentBox.text !== ""

                        onClicked: {
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

                                    closeOrReopen()
                                }
                            })
                        }

                        Behavior on opacity {
                            UbuntuNumberAnimation {}
                        }
                    }

                    Button {
                        text: i18n.tr("Comment")
                        enabled: commentBox.text !== "" || !commentBox.show
                        onClicked: {
                            if (commentBox.show) {
                                issue.comment(commentBox.text)

                                commentBox.text = ""
                                commentBox.show = false
                            } else {
                                commentBox.show = true
                                commentBox.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }

    Sidebar {
        id: sidebar
        mode: "right"
        expanded: wideAspect && !issue.isPullRequest

        Column {
            width: parent.width

            ListItem.Header {
                text: i18n.tr("Milestone")
            }

            ListItem.Standard {
                text: issue.milestone && issue.milestone.hasOwnProperty("number") ? issue.milestone.title : i18n.tr("No milestone")
                visible: !plugin.hasPushAccess
            }

            SuruItemSelector {
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
                    var milestone = undefined
                    if (selectedIndex < model.length - 1)
                        milestone = model[selectedIndex]

                    issue.setMilestone(milestone)
                }
            }

            ListItem.Header {
                text: i18n.tr("Assigned To")
            }

            ListItem.Standard {
                text: issue.assignee && issue.assignee.hasOwnProperty("login") ? issue.assignee.login : i18n.tr("No one assigned")
                visible: !plugin.hasPushAccess
            }

            SuruItemSelector {
                model: plugin.availableAssignees.concat(i18n.tr("No one assigned"))
                visible: plugin.hasPushAccess
                selectedIndex: {
                    if (issue.assignee && issue.assignee.hasOwnProperty("login")) {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i].login === issue.assignee.login)
                                return i
                        }

                        return model.length - 1
                    } else {
                        return model.length - 1
                    }
                }

                delegate: OptionSelectorDelegate {
                    text: modelData.login
                }

                onSelectedIndexChanged: {
                    var login = ""
                    if (selectedIndex < model.length - 1) {
                        login = model[selectedIndex].login

                        busyDialog.text = i18n.tr("Setting assignee to <b>%1</b>").arg(model[selectedIndex].login)
                    } else {
                        busyDialog.text = i18n.tr("Removing assignee from the %1").arg(type)
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

            ListItem.Header {
                id: labelsHeader
                text: i18n.tr("Labels")
            }

            Repeater {
                id: labelsRepeater

                property bool editing

                model: editing ? plugin.availableLabels : issue.labels
                delegate: ListItem.Standard {
                    height: units.gu(5)
                    Label {
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }

                        text: modelData.name
                        color: "#" + modelData.color
                    }

                    control: CheckBox {
                        visible: labelsRepeater.editing

                        checked: {
                            for (var i = 0; i < issue.labels.length; i++) {
                                var label = issue.labels[i]

                                if (label.name === modelData.name)
                                    return true
                            }

                            return false
                        }

                        //onClicked: checked = doc.sync("done", checked)

                        style: SuruCheckBoxStyle {}
                    }
                }
            }

            ListItem.Standard {
                text: i18n.tr("None Yet")
                enabled: false
                visible: issue.labels.length === 0
            }

            ListItem.Standard {
                text: i18n.tr("Edit...")
                visible: plugin.hasPushAccess
                onClicked: PopupUtils.open(labelsPopover, labelsHeader)
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        ToolbarButton { action: editAction }
        ToolbarButton { action: mergeAction; visible: issue.isPullRequest }
        ToolbarButton { action: closeAction }
    }

    property alias busyDialog: busyDialog

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

    Component {
        id: labelsPopover

        Popover {
            id: popover
            property var labels: JSON.parse(JSON.stringify(issue.labels))
            property bool edited: false

            Component.onDestruction: {
                if (edited) {
                    updateLabels(popover.labels)
                }
            }

            contentHeight: labelsColumn.height
            Column {
                id: labelsColumn
                width: parent.width

                ListItem.Header {
                    text: i18n.tr("Available Labels")
                }

                Repeater {
                    id: repeater

                    model: plugin.availableLabels
                    delegate: ListItem.Standard {
                        showDivider: index < repeater.count - 1
                        height: units.gu(5)
                        Label {
                            anchors {
                                left: parent.left
                                leftMargin: units.gu(2)
                                verticalCenter: parent.verticalCenter
                            }

                            text: modelData.name
                            color: "#" + modelData.color
                        }

                        control: CheckBox {
                            checked: {
                                for (var i = 0; i < popover.labels.length; i++) {
                                    var label = popover.labels[i]

                                    if (label.name === modelData.name)
                                        return true
                                }

                                return false
                            }

                            onClicked: {
                                popover.edited = true
                                for (var i = 0; i < popover.labels.length; i++) {
                                    var label = popover.labels[i]

                                    if (label.name === modelData.name) {
                                        popover.labels.splice(i, 1)
                                        return
                                    }
                                }

                                popover.labels.push(modelData)
                            }

                            style: SuruCheckBoxStyle {}
                        }
                    }
                }
            }
        }
    }
}
