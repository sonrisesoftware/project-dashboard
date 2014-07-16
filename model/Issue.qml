import QtQuick 2.0

Ticket {
    id: issue

    property string type: typeRegular
    property string typeRegular: issue.isPullRequest ? "pull request" : "issue"
    property string typeCap: issue.isPullRequest ? "Pull request" : "Issue"
    property string typeTitle: issue.isPullRequest ? "Pull Request" : "Issue"

    property int number: info.number

    property bool isPullRequest: info.hasOwnProperty("pull_request") || info.hasOwnProperty("head") //TODO: Is this the best way to handle it?
    property bool merged: isPullRequest ? pull && pull.merged  ? pull.merged : false
                                        : false
    property bool mergeable: isPullRequest ? pull && pull.mergeable ? pull.mergeable : false
                                           : false
    property bool open: info.state === "open"
    property var assignee: info.assignee

    property var plugin: parent

    property bool ready

    property string state: open ? hasAssignee ? "In Progress" : "New" : "Fixed"

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

    onLoaded: {
        refresh()
        parent.nextNumber = Math.max(parent.nextNumber, issue.number + 1)
    }

    onCreated: {
        refresh()
        parent.nextNumber = Math.max(parent.nextNumber, issue.number + 1)
    }

    property var milestone: info.milestone
    property string title: info.title
    property var labels: info.labels
    property var user: info.user
    property var created_at: info.created_at
    property string body: typeof(info.body) == "string" ? info.body : ""

    function renderBody() {
        return renderMarkdown(body, parent.repo)
    }

    property string summary: {
        var text = i18n.tr("%1 opened this issue %2").arg(issue.user.login).arg(DateUtils.friendlyTime(issue.created_at))
        if (issue.labels.length > 0) {
            text += " | "
            for (var i = 0; i < issue.labels.length; i++) {
                var label = issue.labels[i]
                text += '<font color="#' + label.color + '">' + label.name + '</font>'
                if (i < issue.labels.length - 1)
                    text += ', '
            }
        }

        return text
    }

    property var allEvents: {
        if (!ready)
            return []

        // Turn the list of commits into events
        var commitEvents = []
        for (var i = 0; i < commits.length; i++) {
            commitEvents.push({
                "event": "commit",
                "commits": [commits[i]],
                "actor": commits[i].author,
                "created_at": commits[i].commit.committer.date
            })
        }

        // Sort by date
        var allEvents = comments.concat(events).concat(commitEvents)
        allEvents.sort(function(a, b) {
            return new Date(a.created_at) - new Date(b.created_at)
        })

        // Group together adjacent commits
        var index = 0;
        var count = 0;
        while (index < allEvents.length) {
            var event = allEvents[index]

            if (event && event.event && event.event === "commit") {
                index++
                var login = event.actor.login
                count = 1
                while(count < 5 && index < allEvents.length && allEvents[index].event === "commit" && allEvents[index].actor.login === login) {
                    var nextEvent = allEvents[index]
                    event.commits = event.commits.concat(nextEvent.commits)
                    allEvents.splice(index, 1)
                    count++
                }

                index--
            }

            index++
        }

        ////print("ALL EVENTS", allEvents.length)

        return allEvents
    }

    function refresh() {
        print(parent.name, issue.number, isPullRequest, info._links)
        if (isPullRequest && info._links) {
            print('Calling')
            parent.httpGet(info._links.statuses.href).done(function (data, info) {
                if (info.status == 304) return

                 ////print(data)
                 if (JSON.parse(data)[0] === undefined) {
                     status = ""
                     statusDescription = ""
                 } else {
                     status = JSON.parse(data)[0].state
                     print('ISSUE', parent.name, issue.number, issue.status)
                     statusDescription= JSON.parse(data)[0].description
                 }
             })
        }
    }

    function load() {
        ready = true

        if (isPullRequest) {
            plugin.httpGet('/repos/%1/pulls/%2'.arg(plugin.name).arg(issue.number)).done(function (data, info) {
                if (info.status === 304)
                    return

                pull = JSON.parse(data)
            })

            plugin.httpGet('/repos/%1/pulls/%2/commits'.arg(plugin.name).arg(issue.number)).done(function (data, info) {
                if (info.status === 304)
                    return

                commits = JSON.parse(data)
            })
        }

        plugin.httpGet('/repos/%1/issues/%2/comments'.arg(plugin.name).arg(issue.number)).done(function (data, info) {
            if (info.status === 304)
                return

            comments = JSON.parse(data)
        })

        plugin.httpGet('/repos/%1/issues/%2/events'.arg(plugin.name).arg(issue.number)).done(function (data, info) {
            if (info.status === 304)
                return

            events = JSON.parse(data)
        })
    }
}
