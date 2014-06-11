import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Item {
    id: root
    property var event
    property string type: event.hasOwnProperty("event") ? event.event : "comment"
    visible: (title !== "" || type === "comment") && (wideAspect ? true: bodyText !== "")
    property string author: type === "comment" ? event.user.login : event.actor.login
    property string date: event.created_at ? event.created_at : ""

    property bool last

    property string title: {
        if (type == "referenced") {
            return i18n.tr("<b>%1</b> referenced this issue from a commit %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "assigned") {
            return i18n.tr("Assigned to <b>%1</b> %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "closed") {
            return i18n.tr("<b>%1</b> closed this %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "reopened") {
            return i18n.tr("<b>%1</b> reopened this %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "merged") {
            return i18n.tr("<b>%1</b> merged this %2").arg(author).arg(friendsUtils.createTimeString(date))
        } else if (type == "commit") {
            if (event.commits.length === 1)
                return i18n.tr("<b>%1</b> pushed 1 commit %2").arg(author).arg(friendsUtils.createTimeString(date))
            else
                return i18n.tr("<b>%1</b> pushed %3 commits %2").arg(author).arg(friendsUtils.createTimeString(date)).arg(event.commits.length)
        } else if (type == "testing") {
            var color =  event.status == "success" ? colors["green"]
                                             : event.status == "failure" ? colors["red"]
                                                                   : event.status == "error" ? colors["yellow"] : "white"
            if (color === "white")
                return event.statusDescription
            else
                return "<font color=\"" + color + "\">" + event.statusDescription + "</font>"
        } else {
            return ""
        }
    }

    property string bodyText: {
        if (type == "referenced") {
            return i18n.tr("Referenced the %1 from a commit").arg(typeRegular)
        } else if (type == "assigned") {
            return ""
        } else if (type == "closed") {
            return i18n.tr("Closed the %1").arg(typeRegular)
        } else if (type == "reopened") {
            return i18n.tr("Reopened the %1").arg(typeRegular)
        } else if (type == "merged") {
            return i18n.tr("Merged the %1").arg(typeRegular)
        } else if (type == "commit") {
            return ""
        } else if (type == "comment") {
            return root.event.hasOwnProperty("body") ? renderMarkdown(root.event.body) : ""
        } else if (type === "testing") {
            var color =  event.status == "success" ? colors["green"]
                                             : event.status == "failure" ? colors["red"]
                                                                   : event.status == "error" ? colors["yellow"] : "white"
            if (color === "white")
                return event.statusDescription
            else
                return "<font color=\"" + color + "\">" + event.statusDescription + "</font>"
        } else {
            return ""
        }
    }

    property string icon: {
        if (type == "referenced") {
            return "bookmark-o"
        } else if (type === "assigned") {
            return "user"
        } else if (type === "closed") {
            return "times"
        } else if (type === "reopened") {
            return "plus"
        } else if (type === "merged") {
            return "code-fork"
        } else if (type === "commit") {
            return "code"
        } else if (type === "comment") {
            return "comments-o"
        } else if (type === "testing") {
            return wideAspect ? "check" : "check-circle"
        } else {
            return ""
        }
    }

    width: parent ? parent.width : 0
    height: comment.visible ? comment.height : wideAspect ? wideLayout.height: smallLayout.height

    CommentArea {
        id: comment
        event: root.event
        visible: type === "comment" && wideAspect
        width: parent.width
    }

    ListItem.Empty {
        id: smallLayout
        visible: !wideAspect
        height: row.height + body.height + body.anchors.topMargin + row.anchors.topMargin * 2

        Row {
            id: row
            anchors {
                left: parent.left; leftMargin: units.gu(2)
                top: parent.top; topMargin: units.gu(1)
            }
            spacing: units.gu(1)

            AwesomeIcon {
                name: icon
                anchors.verticalCenter: parent.verticalCenter
                size: units.gu(2)
                color: type == "closed" ? colors["red"]
                                        : type === "reopened" ? colors["green"]
                                                              : type === "merged" ? colors["blue"]
                                                                                  : Theme.palette.normal.baseText
            }

            Label {
                text: author
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label {
            anchors {
                right: parent.right
                rightMargin: row.anchors.leftMargin
                top: parent.top; topMargin: row.anchors.topMargin
            }
            font.italic: true
            text: type === "testing" ? "" : friendsUtils.createTimeString(date)
        }

        Label {
            id: body
            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(2)
                top: row.bottom
                topMargin: units.gu(0.1)
            }
            text: bodyText
            textFormat: type == "comment" || type === "testing" ? Text.RichText : Text.PlainText
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            opacity: 0.7
        }
    }

    Rectangle {
        width: 1
        visible: wideAspect
        x: units.gu(1.5)
        y: -units.gu(1)
        height: units.gu(1) + (last || type === "comment" ? 0 : parent.height)
        z: -100
        //color: Qt.rgba(0.5,0.5,0.5,0.5)
        color: Qt.rgba(0.6,0.6,0.6,1)
    }

    Item {
        id: wideLayout
        width: parent.width
        height: eventItem.height + commitsColumn.anchors.topMargin + commitsColumn.height
        visible: wideAspect

        Row {
            id: eventItem
            width: parent.width
            visible: type !== "comment"
            spacing: units.gu(1)

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: height
                height: units.gu(3)
                radius: height/2
                color: type == "closed" ? colors["red"]
                                        : type === "reopened" ? colors["green"]
                                                              : type === "merged" ? colors["blue"]
                                                                                  : Qt.rgba(0.6,0.6,0.6,1)
                antialiasing: true

                AwesomeIcon {
                    name: icon
                    anchors.centerIn: parent
                }
            }

            Label {
                id: titleLabel
                text: title
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Column {
            id: commitsColumn
            anchors.top: eventItem.bottom
            anchors.topMargin: units.gu(0.5)
            width: parent.width - x
            x: titleLabel.x

            property bool wide: width > units.gu(50)

            Repeater {
                model: event.hasOwnProperty("commits") ? event.commits : []
                delegate: Item {
                    id: commitItem
                    width: parent.width
                    height: msgLabel.height

                    Label {
                        id: msgLabel
                        text: " • " + modelData.commit.message
                        font.family: "Monospaced"
                        width: commitsColumn.wide ? 0.8 * parent.width : commitsColumn.width
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }

                    Label {
                        id: shaLabel
                        text: modelData.sha.substring(0, 7)
                        font.family: "Monospaced"
                        width: 0.2 * parent.width
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        color: Theme.palette.normal.backgroundText
                        horizontalAlignment: Text.AlignRight
                        visible: commitsColumn.wide
                    }
                }
            }
        }
    }
}
