import QtQuick 2.0
import Ubuntu.Components 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../../ubuntu-ui-extras"

Column {
    id: column
    width: parent.width
    spacing: units.gu(1)

    property bool showOptions
    property Issue issue

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
            UbuntuShape {
                id: stateShape
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
                text: issue.isPullRequest ? issue.merged ? i18n.tr("<b>%1</b> merged %2 commits").arg(issue.user.login).arg(issue.commits.length)
                                                         : i18n.tr("<b>%1</b> wants to merge %2 commits").arg(issue.user.login).arg(issue.commits.length)
                : i18n.tr("<b>%1</b> opened this issue %2").arg(issue.user.login).arg(friendsUtils.createTimeString(issue.created_at))
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - stateShape.width - parent.spacing
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }

    Column {
        id: optionsColumn
        width: parent.width

        property bool hide: !showOptions
        visible: opacity > 0

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
                UbuntuNumberAnimation {
                    target: optionsColumn
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

        SuruItemSelector {
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

        ListItem.Standard {
            text: issue.assignee && issue.assignee.hasOwnProperty("login") ? issue.assignee.login : i18n.tr("No one assigned")
            visible: !plugin.hasPushAccess
            height: units.gu(5)
        }

        SuruItemSelector {
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

            delegate: OptionSelectorDelegate {
                text: modelData.login
            }

            onSelectedIndexChanged: {
                var assignee = undefined
                if (selectedIndex < model.length - 1)
                    assignee = model[selectedIndex]

                issue.setAssignee(assignee)
            }
        }

        ListItem.Standard {
            id: labelsItemSmall

            text: issue.labels.length > 0 ? "" : i18n.tr("No labels")

            height: issue.labels.length > 0 ? units.gu(5) : labelFlowSmall.height + units.gu(2)
            progression: plugin.hasPushAccess
            onClicked: if (progression) PopupUtils.open(labelsPopover, labelsItemSmall)

            Flow {
                id: labelFlowSmall

                spacing: units.gu(1)
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                    rightMargin: progression ? units.gu(4) : units.gu(2)
                }

                Repeater {
                    model: issue.labels

                    delegate: UbuntuShape {
                        id: labelContainer
                        color: "#" + modelData.color
                        width: labelName.contentWidth < labelFlowSmall.width ? labelName.contentWidth + units.gu(2) : labelFlowSmall.width - units.gu(2)
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
                                    return UbuntuColors.coolGrey
                                else
                                    return Theme.palette.normal.baseText
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

    UbuntuShape {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
        height: body.height + units.gu(2)
        color: Theme.palette.normal.field

        Label {
            id: body
            text: empty ? "No description" : issue.renderBody()
            property bool empty: issue.body === ""
            color: empty ? Theme.palette.normal.backgroundText : Theme.palette.selected.backgroundText
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
}
