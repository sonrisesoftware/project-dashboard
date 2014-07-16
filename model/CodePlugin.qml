import QtQuick 2.0
import "internal" as Internal

Internal.CodePlugin {


    property var assignedIssues: List.filter(issues, function(issue) {
        return true// issue.assignedToMe && issue.open && !issue.isPullRequest
    })

    property var openIssues: List.filter(issues, function(issue) {
        return issue.open && !issue.isPullRequest
    })

    property var openPulls: List.filter(issues, function(issue) {
        return issue.open && issue.isPullRequest
    })

    function httpGet(call) {
        return pluginView.service.httpGet(call)
    }

    property int nextNumber: 1

    property var milestones: []
    property var availableAssignees: []

    property var components: []

}
