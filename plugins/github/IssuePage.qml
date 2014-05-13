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

import "../../components"
import "../../backend/utils.js" as Utils
import "../../backend/"

Page {
    id: page
    
    title: i18n.tr("%2 %1").arg(issue.number).arg(typeTitle)

    property string type: typeRegular
    property string typeRegular: issue.isPullRequest ? "pull request" : "issue"
    property string typeCap: issue.isPullRequest ? "Pull request" : "Issue"
    property string typeTitle: issue.isPullRequest ? "Pull Request" : "Issue"

    property Plugin plugin
    property var request

    property Issue issue

    Component.onCompleted: issue.load()

    InputDialog {
        id: mergeDialog
        title: i18n.tr("Merge Pull Request")
        text: i18n.tr("Enter the commit message for the merge:")

        onAccepted: {
            mergeDialog.hide()
            issue.merge(value)
        }
    }

    rightWidgets: [
        Button {
            id: editAction
            text: i18n.tr("Edit")
            iconName: "pencil-square-o"
            enabled: plugin.hasPushAccess
            onClicked: PopupUtils.open(editSheet, page)
        },

        Button {
            id: mergeAction
            text: i18n.tr("Merge")
            iconName: "code-fork"
            enabled: plugin.hasPushAccess && issue.isPullRequest && !issue.merged && issue.mergeable
            onClicked: mergeDialog.show()
            visible: issue.isPullRequest
        },

        Button {
            id: closeAction
            text: issue.open ? i18n.tr("Close") : i18n.tr("Reopen")
            iconName: issue.open ? "times" : getIcon("reset")
            enabled: !issue.merged && plugin.hasPushAccess
            onClicked: {
                issue.closeOrReopen()
            }
        }
    ]



    Flickable {
        id: mainFlickable
        clip: true
        anchors {
            left: parent.left
            right: sidebar.left
            top: parent.top
            bottom: parent.bottom
        }

        contentHeight: column.height + (sidebar.expanded ? units.gu(4) : units.gu(2))
        contentWidth: width

        Column {
            id: column
            width: parent.width
            spacing: units.gu(1)
            anchors {
                top: parent.top
                topMargin: sidebar.expanded ? units.gu(2) : units.gu(1)
                left: parent.left
                right: parent.right
            }

            Column {
                anchors {
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
                    width: parent.width
                    spacing: units.gu(1)
                    Rectangle {
                        id: stateShape
                        height: stateLabel.height + units.gu(1)
                        width: stateLabel.width + units.gu(2)
                        color: issue.merged ? colors["blue"] : issue.open ? colors["green"] : colors["red"]
                        border.color: Qt.darker(color, 1.2)
                        radius: units.gu(0.5)
                        anchors.verticalCenter: parent.verticalCenter

                        Label {
                            id: stateLabel
                            anchors.centerIn: parent
                            text: issue.merged ? i18n.tr("Merged") : issue.open ? i18n.tr("Open") : i18n.tr("Closed")
                            color: "white"
                        }
                    }

                    Label {
                        text: issue.isPullRequest ? issue.merged ? i18n.tr("<b>%1</b> merged %2 commits").arg(issue.user.login).arg(issue.commits.length)
                                                                 : i18n.tr("<b>%1</b> wants to merge %2 commits").arg(issue.user.login).arg(issue.commits.length)
                                                  : i18n.tr("<b>%1</b> opened this issue %2").arg(issue.user.login).arg(friendlyTime(issue.created_at))
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - stateShape.width - parent.spacing
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }

            Column {
                id: optionsColumn
                width: parent.width

                property bool hide: sidebar.expanded || issue.isPullRequest

                states: [
                    State {
                        when: optionsColumn.hide
                        PropertyChanges {
                            restoreEntryValues: true
                            target: optionsColumn
                            height: 0
                            opacity: 0
                        }
                    },
                    State {
                        when: !optionsColumn.hide
                        PropertyChanges {
                            restoreEntryValues: true
                            target: optionsColumn
                            height: optionsColumn.implicitHeight
                            opacity: 1
                        }
                    }

                ]

                transitions: [
                    Transition {
                        from: "*"
                        to: "*"
                        NumberAnimation {
                            target: optionsColumn
                            duration: 200
                            properties: "height, opacity"
                        }
                    }
                ]

                ListItem.ThinDivider {}

                ListItem.Standard {
                    text: issue.milestone && issue.milestone.hasOwnProperty("number") ? issue.milestone.title : i18n.tr("No milestone")
                    visible: !plugin.hasPushAccess
                    height: units.gu(5)
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
                            return model.length - 1
                        } else {
                            return model.length - 1
                        }
                    }

                    delegate: OptionDelegate {
                        text: modelData.title || modelData
                    }

                    onSelectedIndexChanged: {
                        var milestone = undefined
                        if (selectedIndex < model.length - 1)
                            milestone = model[selectedIndex]

                        issue.setMilestone(milestone)
                    }
                }

                ListItem.Standard {
                    text: issue.assignee && issue.assignee.hasOwnProperty("login") ? issue.assignee.login : i18n.tr("No one assigned")
                    visible: !plugin.hasPushAccess
                    height: units.gu(5)
                }

                ListItem.ItemSelector {
                    model: plugin.availableAssignees.concat(i18n.tr("No one assigned"))
                    visible: plugin.hasPushAccess
                    selectedIndex: {
                        print("ASSIGNEE:", JSON.stringify(issue.assignee))
                        if (issue.assignee && issue.assignee.hasOwnProperty("login")) {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i].login === issue.assignee.login) {
                                    print("Assignee Index:", i)
                                    return i
                                }
                            }

                            return model.length - 1
                        } else {
                            return model.length - 1
                        }
                    }

                    delegate: OptionDelegate {
                        text: modelData.login || modelData
                    }

                    onSelectedIndexChanged: {
                        var assignee = undefined
                        if (selectedIndex < model.length - 1)
                            assignee = model[selectedIndex]

                        issue.setAssignee(assignee)
                    }
                }

                ListItem.Standard {
                    id: labelsItem
                    text: {
                        if (issue.labels.length > 0) {
                            var text = ""
                            for (var i = 0; i < issue.labels.length; i++) {
                                var label = issue.labels[i]
                                text += '<font color="#' + label.color + '">' + label.name + '</font>'
                                if (i < issue.labels.length - 1)
                                    text += ', '
                            }
                            return text
                        } else {
                            return i18n.tr("No labels")
                        }
                    }

                    height: units.gu(5)
                    progression: plugin.hasPushAccess
                    onClicked: PopupUtils.open(labelsPopover, labelsItem)
                }
            }

            //TextArea {
            //                id: textArea
            //                width: parent.width
            //                text: issue.renderBody()
            //                height: Math.max(__internal.linesHeight(4), edit.height + textArea.__internal.frameSpacing * 2)
            //                placeholderText: i18n.tr("No description set.")
            //                readOnly: true
            //                textFormat: Text.RichText
            //                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

            //                // FIXME: Hack necessary to get the correct line height
            //                TextEdit {
            //                    id: edit
            //                    visible: false
            //                    width: parent.width
            //                    textFormat: Text.RichText
            //                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            //                    text: textArea.text
            //                    font: textArea.font
            //                }
            //            }

            BackgroundView {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                radius: units.gu(0.5)
                height: body.height + units.gu(2)

                Label {
                    id: body
                    text: empty ? "No description" : issue.renderBody()
                    property bool empty: issue.body === ""
                    opacity: empty ? 0.5 : 1
                    width: parent.width - units.gu(2)
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    anchors.centerIn: parent
                    textFormat: Text.RichText

                    onLinkActivated: {
                        var bugNumber = link.split("/", 7)[6] // This gives us the bug number
                        var index = null
                        var linkIssue

                        for (var i = 0; i < plugin.issues.count;i++) {
                            if (bugNumber == plugin.issues.get(i).modelData.number)
                                index = i
                        }

                        if (index == null)
                            console.log("Bug not found")
                        else {
                            linkIssue = plugin.issues.get(index).modelData
                            pageStack.push(Qt.resolvedUrl("IssuePage.qml"), {issue: linkIssue, plugin:plugin})
                        }
                    }
                }
            }

            Column {
                id: eventColumn
                anchors {
                    margins: wideAspect ? units.gu(2) : 0
                    left: parent.left
                    right: parent.right
                }

                spacing: wideAspect ? parent.spacing : 0

                ListItem.ThinDivider {
                    visible: !wideAspect
                }

                ListItem.Standard {
                    text: i18n.tr("Commits")
                    progression: true
                    height: visible ? units.gu(5) : 0
                    visible: issue.isPullRequest && !wideAspect
                    onClicked: pageStack.push(commitsPage)
                }

                Repeater {
                    model: issue.allEvents
                    delegate: EventItem {
                        id: eventItem
                        event: modelData
                        last: eventItem.y + eventItem.height == eventColumn.height
                    }
                }

                EventItem {
                    event: {
                        "event": "testing",
                                "actor": {
                            "login": i18n.tr("Continous Integration")
                        },
                        "statusDescription": issue.statusDescription,
                                "status": issue.status
                    }
                    last: true
                    visible: issue.status !== ""
                }
            }

            Column {
                anchors {
                    margins: units.gu(2)
                    left: parent.left
                    right: parent.right
                }
                spacing: units.gu(1)

                TextArea {
                    id: commentBox
                    width: parent.width

                    property bool show

                    height: show ? units.gu(15) : 0

                    onHeightChanged: {
                        mainFlickable.contentY = mainFlickable.contentHeight - mainFlickable.height
                    }

                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }
                }

                Item {
                    width: parent.width
                    height: childrenRect.height

                    Icon {
                        id: eventLoadingIndicator
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                        }
                        visible: issue.loading > 0
                        name: visible ? "spinner-rotate" : "spinner"
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

                            opacity: commentBox.show ? 1 : 0

                            onClicked: {
                                commentBox.text = ""
                                commentBox.show = false
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }
                        }

                        Button {
                            text:  issue.open ? i18n.tr("Comment and Close") : i18n.tr("Comment and Reopen")
                            style: issue.open ? "danger" : "success"

                            visible: wideAspect
                            opacity: commentBox.show ? 1 : 0
                            enabled: commentBox.text !== ""

                            onClicked: {
                                issue.comment(commentBox.text)
                                issue.closeOrReopen()

                                commentBox.text = ""
                                commentBox.show = false
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }
                        }

                        Button {
                            text: i18n.tr("Comment")
                            style: "info"
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
    }

    Sidebar {
        id: sidebar
        mode: "right"
        //anchors.bottom: toolbar.top
        expanded: wideAspect && !issue.isPullRequest

        Column {
            id: sidebarColumn
            width: parent.width

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
                        return model.length - 1
                    } else {
                        return model.length - 1
                    }
                }

                delegate: OptionDelegate {
                    text: modelData.title || modelData
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

            ListItem.ItemSelector {
                model: plugin.availableAssignees.concat(i18n.tr("No one assigned"))
                visible: plugin.hasPushAccess
                selectedIndex: {
                    //print("ASSIGNEE:", JSON.stringify(issue.assignee))
                    if (issue.assignee && issue.assignee.hasOwnProperty("login")) {
                        for (var i = 0; i < model.length; i++) {
                            if (model[i].login === issue.assignee.login) {
                                //print("Assignee Index:", i)
                                return i
                            }
                        }

                        return model.length - 1
                    } else {
                        return model.length - 1
                    }
                }

                delegate: OptionDelegate {
                    text: modelData.login || modelData
                }

                onSelectedIndexChanged: {
                    var assignee = undefined
                    if (selectedIndex < model.length - 1)
                        assignee = model[selectedIndex]

                    issue.setAssignee(assignee)
                }
            }

            ListItem.Header {
                id: labelsHeader
                text: i18n.tr("Labels")
            }
        }

        Flow {
            id: labelFlow

            spacing: units.gu(1)
            anchors {
                top: sidebarColumn.bottom
                left: parent.left
                right: parent.right
                topMargin: units.gu(1)
                margins: units.gu(2)
            }

            Repeater {
                id: labelsRepeater

                model: issue.labels
                delegate: BackgroundView {
                    id: labelContainer
                    color: "#" + modelData.color
                    border.color: Qt.darker(color, 1.4)
                    radius: units.gu(0.5)
                    width: labelName.contentWidth < labelFlow.width ? labelName.contentWidth + units.gu(2) : labelFlow.width - units.gu(2)
                    height: units.gu(3.5)

                    Label {
                        id: labelName

                        // Function to get the text color based on the background
                        function getTextColor(backgroundColor) {
                            var red = parseInt((backgroundColor).substring(0,2),16)
                            var green = parseInt((backgroundColor).substring(2,4),16)
                            var blue = parseInt((backgroundColor).substring(4,6),16)

                            var a = 1 - ( 0.299 * red + 0.587 * green + 0.114 * blue)/255;

                            if (a < 0.3)
                                return "#333"
                            else
                                return "white"
                        }

                        text: modelData.name
                        elide: Text.ElideRight
                        anchors.centerIn: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: getTextColor(modelData.color)
                        width: labelContainer.width === labelFlow.width - units.gu(2) ? null : labelFlow.width - units.gu(2)
                    }
                }
            }
        }

        Column {
            width: parent.width
            anchors.top: labelFlow.bottom
            anchors.topMargin: noLabelMessage.visible ? -units.gu(1) : units.gu(1)

            ListItem.ThinDivider {
                visible: !noLabelMessage.visible
            }

            ListItem.Standard {
                id: noLabelMessage
                text: i18n.tr("None Yet")
                enabled: false
                visible: issue.labels.length === 0
            }

            ListItem.Standard {
                text: i18n.tr("Edit...")
                visible: plugin.hasPushAccess
                onClicked: labelsPopover.open()
            }
        }
    }

    Component {
        id: commitsPage

        Page {
            title: i18n.tr("Commits")

            ListView {
                id: commitsList
                anchors.fill: parent
                model: issue.commits
                delegate: SubtitledListItem {
                    text: modelData.commit.message
                    subText: i18n.tr("%1 - %2 - %3").arg(modelData.sha.substring(0, 7)).arg(modelData.author.login).arg(friendsUtils.createTimeString(modelData.commit.committer.date))
                }
            }

            Label {
                anchors.centerIn: parent
                fontSize: "large"
                opacity: 0.5
                visible: commitsList.count === 0
                text: i18n.tr("No commits")
            }

            ScrollBar {
                flickableItem: commitsList
            }
        }
    }

    SelectorSheet {
        id: labelsPopover
        property var labels: JSON.parse(JSON.stringify(issue.labels))
        property bool edited: false

        title: i18n.tr("Labels")

        onAccepted: {
            if (edited) {
                issue.updateLabels(labelsPopover.labels)
            }
        }


        model: plugin.availableLabels
        delegate: ListItem.Standard {
            height: units.gu(5)

            Rectangle {
                id: labelTag
                width: units.gu(3)
                height: width
                color: "#" + modelData.color
                border.color: Qt.darker(color, 1.4)
                radius: units.gu(0.5)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }
            }

            Label {
                anchors {
                    left: labelTag.right
                    leftMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                text: modelData.name
            }

            CheckBox {
                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    verticalCenter: parent.verticalCenter
                }

                selected: {
                    for (var i = 0; i < labelsPopover.labels.length; i++) {
                        var label = labelsPopover.labels[i]
                            if (label.name === modelData.name)
                                return true
                    }


                    return false
                }

                onClicked: {
                    labelsPopover.edited = true
                    for (var i = 0; i < labelsPopover.labels.length; i++) {
                        var label = labelsPopover.labels[i]

                        if (label.name === modelData.name) {
                            labelsPopover.labels.splice(i, 1)
                            return
                        }
                    }

                    labelsPopover.labels.push(modelData)
                }
            }
        }
    }

//    Component {
//        id: editSheet
//        ComposerSheet {
//            id: sheet

//            title: issue.isPullRequest ? i18n.tr("Edit Pull") : i18n.tr("Edit Issue")

//            Component.onCompleted: {
//                sheet.__leftButton.text = i18n.tr("Cancel")
//                sheet.__leftButton.color = "gray"
//                sheet.__rightButton.text = i18n.tr("Update")
//                sheet.__rightButton.color = sheet.__rightButton.__styleInstance.defaultColor
//                sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruSheetStyle.qml"), sheet)
//            }

//            property string repo
//            property var action

//            onConfirmClicked: {
//                PopupUtils.close(sheet)
//                issue.edit(nameField.text, descriptionField.text)
//            }

//            TextField {
//                id: nameField
//                placeholderText: i18n.tr("Title")
//                anchors {
//                    left: parent.left
//                    top: parent.top
//                    right: parent.right
//                    //margins: units.gu(1)
//                }
//                text: issue.title
//                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

//                Keys.onTabPressed: descriptionField.forceActiveFocus()
//            }

//            TextArea {
//                id: descriptionField
//                placeholderText: i18n.tr("Description")
//                text: issue.body
//                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

//                anchors {
//                    left: parent.left
//                    right: parent.right
//                    top: nameField.bottom
//                    bottom: parent.bottom
//                    topMargin: units.gu(1)
//                }
//            }
//        }

//    }

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
