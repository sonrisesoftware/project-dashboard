import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/listutils.js" as List

Internal.CodePlugin {
    id: plugin

    property bool hasPushAccess: false

    property var assignedIssues: List.filter(issues, function(issue) {
        return  issue.assignedToMe && issue.open && !issue.isPullRequest
    })

    property var openIssues: List.filter(issues, function(issue) {
        return issue.open && !issue.isPullRequest
    })

    property var openPulls: List.filter(issues, function(issue) {
        return issue.open && issue.isPullRequest
    })

    property int nextNumber: 1

    function getComponent(issue) {
        if (componentFunction !== "") {
            return eval(componentFunction)(issue)
        } else {
            var title = issue.title

            if (title.match(/\[.*\].*/) !== null) {
                var index = title.indexOf(']')
                var component = title.substring(1, index)

                return component
            } else {
                return ""
            }
        }
    }

    function httpGet(call) {
        return pluginView.service.httpGet(call)
    }
}
