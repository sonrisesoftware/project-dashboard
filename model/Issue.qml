import QtQuick 2.0
import "internal" as Internal

Internal.Issue {
    id: issue

    property int number: info.number

    property bool isPullRequest: info.hasOwnProperty("pull_request") || info.hasOwnProperty("head") //TODO: Is this the best way to handle it?
    //property bool merged: isPullRequest ? pull && pull.merged  ? pull.merged : false
    //                                    : false
    //property bool mergeable: isPullRequest ? pull && pull.mergeable ? pull.mergeable : false
    //                                       : false
    property bool open: info.state === "open"
    property var assignee: info.assignee

    property bool assignedToMe: {
        var result = issue.assignee && issue.assignee.login && issue.assignee.login === githubPlugin.user.login
        if (result === undefined)
            return false
        else
            return result
    }

    property bool hasAssignee: {
        var result = issue.assignee && issue.assignee.login
        if (result === undefined)
            return false
        else
            return result
    }

    property bool hasMilestone: {
        var result = issue.milestone && issue.milestone.title
        if (result === undefined)
            return false
        else
            return result
    }

    property var milestone: info.milestone
    property string title: info.title
    property var labels: info.labels
    property var user: info.user
    property var created_at: info.created_at
    property string body: typeof(info.body) == "string" ? info.body : ""
}
