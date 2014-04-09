import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../ubuntu-ui-extras"
import "../../backend/utils.js" as Utils

Object {
    id: issue

    function toJSON() { return doc.toJSON() }
    function fromJSON(json) { doc.fromJSON(json) }

    Document {
        id: doc

        onSave: {
            doc.set("info", info)
            doc.set("pull", pull)
            doc.set("events", events)
            doc.set("comments", comments)
            doc.set("commits", commits)
            doc.set("status", status)
            doc.set("statusDescription", statusDescription)
        }
    }

    property string type: typeRegular
    property string typeRegular: issue.isPullRequest ? "pull request" : "issue"
    property string typeCap: issue.isPullRequest ? "Pull request" : "Issue"
    property string typeTitle: issue.isPullRequest ? "Pull Request" : "Issue"

    property var info: doc.get("info", {})
    property var pull: doc.get("pull", undefined)
    property var events: doc.get("events", [])
    property var comments: doc.get("comments", [])
    property var commits: doc.get("commits", [])

    property int number: info.number

    property bool loaded

    property bool isPullRequest: info.hasOwnProperty("pull_request") || info.hasOwnProperty("head") //TODO: Is this the best way to handle it?
    property bool merged: isPullRequest ? pull && pull.merged  ? pull.merged : false
                                        : false
    property bool mergeable: isPullRequest ? pull && pull.mergeable ? pull.mergeable : false
                                           : false
    property bool open: info.state === "open"
    property var assignee: info.assignee
    property bool assignedToMe: {
        var result = issue.assignee && issue.assignee.login && issue.assignee.login === github.user.login
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
    property string status: doc.get("status", "")
    property string statusDescription: doc.get("statusDescription", "")

    function renderBody() {
        return renderMarkdown(body, plugin.repo)
    }

    signal error(var title, var message)
    signal busy(var title, var message, var request)
    signal complete()

    function newEvent(type, actor) {
        if (actor === undefined)
            actor = github.user
        events.push({
                        event: type,
                        actor: actor,
                        created_at: new Date().toJSON()
                    })
        events = events
        plugin.changed = true
    }

    function newComment(text) {
        comments.push({body: text, user: github.user, created_at: new Date().toISOString()})
        comments = comments
        plugin.changed = true
        notification.show(i18n.tr("Comment posted"))
    }

    property int syncId: -1

    property var allEvents: {
        if (!loaded)
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

        //print("ALL EVENTS", allEvents.length)

        return allEvents
    }

    function refresh(id) {
        if (isPullRequest && info._links) {
            github.get(project, id, info._links.statuses.href, function(status, response) {
                if (status === 304)
                    return

                plugin.changed = true

                 //print(response)
                 if (JSON.parse(response)[0] === undefined) {
                     doc.set("status", "")
                     doc.set("statusDescription", "")
                 } else {
                     doc.set("status", JSON.parse(response)[0].state)
                     doc.set("statusDescription", JSON.parse(response)[0].description)
                 }
             })
        }
    }

    function load() {
        loaded = true

        var id = project.syncQueue.newGroup(i18n.tr("Updating issue <b>%1</b>").arg(number))

        if (isPullRequest) {
            github.getPullRequest(project, id, plugin.repo, number, function(status, response) {
                if (status === 304)
                    return

                plugin.changed = true

                doc.set("pull", JSON.parse(response))
                print("MERGED:", JSON.parse(response).merged, pull.merged)
                print("MERGEABLE:", JSON.parse(response).mergeable, pull.mergeable)
            })

            github.getPullCommits(project, id, plugin.repo, issue, function(status, response) {
                if (status === 304)
                    return

                plugin.changed = true

                doc.set("commits", JSON.parse(response))
            })
        }

        github.getIssueComments(project, id, plugin.repo, issue, function(status, response) {
            if (status === 304)
                return
            plugin.changed = true
            doc.set("comments", JSON.parse(response))
        })

        github.getIssueEvents(project, id, plugin.repo, issue, function(status, response) {
            if (status === 304)
                return
            plugin.changed = true
            doc.set("events", JSON.parse(response))
        })
    }

    function merge(message) {
        info.state = "closed"
        info = info
        newEvent("merged")
        newEvent("closed")
        var request = github.mergePullRequest(project, plugin.repo, number, message)
        notification.show(i18n.tr("Pull request merged"))
    }

    function closeOrReopen() {
        if (open) {
            github.editIssue(project, plugin.repo, number, {"state": "closed"}, i18n.tr("Closing %2 <b>%1</b>").arg(number).arg(type))
            info.state = "closed"
            info = info
            newEvent("closed")
            notification.show(i18n.tr("%1 closed").arg(typeCap))
        } else {
            github.editIssue(project, plugin.repo, number, {"state": "open"}, i18n.tr("Reopening issue <b>%1</b>").arg(number))

            info.state = "open"
            info = info
            newEvent("reopened")
            notification.show(i18n.tr("%1 reopened").arg(typeCap))
        }
    }

    function setMilestone(milestone) {
        if (issue.milestone && issue.milestone.hasOwnProperty("number") && milestone && issue.milestone.number === milestone.number)
            return

        if (!(issue.milestone && issue.milestone.hasOwnProperty("number")) && !milestone)
            return

        github.editIssue(project, plugin.repo, issue.number, {"milestone": milestone ? milestone.number : ""}, i18n.tr("Changing milestone for issue <b>%1</b>").arg(number))

        info.milestone = milestone
        info = info
        plugin.changed = true
        notification.show(i18n.tr("Milestone changed"))
    }

    function setAssignee(assignee) {
        var login = assignee ? assignee.login : ""

        if (issue.assignee && issue.assignee.hasOwnProperty("login") && issue.assignee.login === login)
            return

        if (!(issue.assignee && issue.assignee.hasOwnProperty("login")) && login === "")
            return

        github.editIssue(project, plugin.repo, issue.number, {"assignee": login}, i18n.tr("Changing assignee for issue <b>%1</b>").arg(number))

        if (login !== "") {
            info.assignee = assignee
            newEvent("assigned", assignee)
        } else {
            info.assignee = undefined
        }
        info = info
        notification.show(i18n.tr("Assignee changed"))
    }

    function updateLabels(labels) {
        var labelNames = []
        for (var i = 0; i < labels.length; i++) {
            labelNames.push(labels[i].name)
        }

        info.labels = labels
        info = info

        var request = github.editIssue(project, plugin.repo, issue.number, {"labels": labelNames}, i18n.tr("Changing labels for issue <b>%1</b>").arg(number))
        notification.show(i18n.tr("Labels updated"))
    }

    function edit(title, body) {
        github.editIssue(project, plugin.repo, issue.number, {"title": title, "body": body}, i18n.tr("Changing title and description for issue <b>%1</b>").arg(number))

        info.title = title
        info.body = body
        info = info
        plugin.changed = true
        notification.show(i18n.tr("%1 updated").arg(typeCap))
    }

    function comment(text) {
        github.newIssueComment(project, plugin.repo, issue, text)

        newComment(text)
    }
}
