import QtQuick 2.0
import Ubuntu.Components 0.1

Item {
    id: root
    property var event
    property string type: event.hasOwnProperty("event") ? event.event : "comment"
    visible: title !== "" || type === "comment"
    property string author: type === "comment" ? event.user.login : event.actor.login
    property string date: event.created_at

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
        } else {
            return ""
        }
    }

    width: parent.width
    height: type === "comment" ? comment.height : eventItem.height

    Rectangle {
        width: 1
        x: units.gu(1.5)
        y: -height
        height: units.gu(1)
        z: -100
        //color: Qt.rgba(0.5,0.5,0.5,0.5)
        color: Qt.rgba(0.6,0.6,0.6,1)
    }

    CommentArea {
        id: comment
        event: root.event
        visible: type === "comment"
        width: parent.width
    }

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
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
