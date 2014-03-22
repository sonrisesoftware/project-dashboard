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

    property var info: doc.get("info", {})
    property var pull: doc.get("pull", undefined)
    property var events: doc.get("events", [])
    property var comments: doc.get("comments", [])
    property var commits: doc.get("commits", [])

    property int number: info.number

    property int loading

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

    property bool loaded

    function newEvent(type, actor) {
        if (actor === undefined)
            actor = github.user
        events.push({
                        event: type,
                        actor: actor,
                        created_at: new Date().toJSON()
                    })
        events = events
    }

    function newComment(text) {
        comments.push({body: text, user: github.user, date: new Date().toISOString()})
        comments = comments
    }

    property var allEvents: {

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
        allEvents = allEvents.sort(function(a, b) {
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

    Component.onCompleted: load()

    function load() {

        if (isPullRequest) {
            github.get(info._links.statuses.href, function(status, response) {
                if (status === 304)
                    return

                 //print(response)
                 if (JSON.parse(response)[0] === undefined) {
                     doc.set("status", "")
                     doc.set("statusDescription", "")
                 } else {
                     doc.set("status", JSON.parse(response)[0].state)
                     doc.set("statusDescription", JSON.parse(response)[0].description)
                 }
             })

            github.getPullRequest(plugin.repo, number, function(status, response) {
                if (status === 304)
                    return

                doc.set("pull", JSON.parse(response))
                print("MERGED:", JSON.parse(response).merged, pull.merged)
                print("MERGEABLE:", JSON.parse(response).mergeable, pull.mergeable)
            })

            github.getPullCommits(plugin.repo, issue, function(status, response) {
                if (status === 304)
                    return

                doc.set("commits", JSON.parse(response))
            })
        }

        github.getIssueComments(plugin.repo, issue, function(status, response) {
            if (status === 304)
                return
            doc.set("comments", JSON.parse(response))
        })

        github.getIssueEvents(plugin.repo, issue, function(status, response) {
            if (status === 304)
                return
            doc.set("events", JSON.parse(response))
        })
    }

    function merge(message) {
        var request = github.mergePullRequest(plugin.repo, number, message, function(has_error, status, response) {
            complete()
            try {
                var json = JSON.parse(response)
                if (json.merged) {
                    info.state = "closed"
                    doc.set("info", info)
                    newEvent("closed")
                    newEvent("merged")
                } else {
                    error(i18n.tr("Connection Error"), i18n.tr("Unable to merge %1:\n\n%2").arg(type).arg(json.message))
                }
            } catch (e) {
               error(i18n.tr("Connection Error"), i18n.tr("Unable to merge %1. Check your connection and/or firewall settings.").arg(type))
            }
        })

        busy(i18n.tr("Merging %1").arg(typeCap),
             i18n.tr("Merging %2 <b>#%1</b>").arg(number).arg(type),
             request)
    }

    function closeOrReopen() {
        if (open) {
            github.editIssue(plugin.repo, number, {"state": "closed"})
            info.state = "closed"
            info = info
            newEvent("closed")
        } else {
            github.editIssue(plugin.repo, number, {"state": "open"})

            info.state = "open"
            info = info
            newEvent("reopened")
        }
    }

    function setMilestone(milestone) {
        if (issue.milestone && issue.milestone.hasOwnProperty("number") && milestone && issue.milestone.number === milestone.number)
            return

        if (!(issue.milestone && issue.milestone.hasOwnProperty("number")) && !milestone)
            return

        github.editIssue(plugin.repo, issue.number, {"milestone": milestone ? milestone.number : ""})

        info.milestone = milestone
        doc.set("info", info)
    }

    function setAssignee(assignee) {
        var login = assignee ? assignee.login : ""

        if (issue.assignee && issue.assignee.hasOwnProperty("login") && issue.assignee.login === login)
            return

        if (!(issue.assignee && issue.assignee.hasOwnProperty("login")) && login === "")
            return

        github.editIssue(plugin.repo, issue.number, {"assignee": login})

        if (login !== "") {
            info.assignee = assignee
            doc.set("info", info)
            newEvent("assigned", assignee)
        } else {
            info.assignee = undefined
            doc.set("info", info)
        }
    }

    function updateLabels(labels) {
        var labelNames = []
        for (var i = 0; i < labels.length; i++) {
            labelNames.push(labels[i].name)
        }

        var request = github.editIssue(plugin.repo, issue.number, {"labels": labelNames}, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to change the labels. Check your connection and/or firewall settings."))
            } else {
                info.labels = labels
                doc.set("info", info)
            }
        })

        busy(i18n.tr("Changing Labels"), i18n.tr("Changes the labels for the issue"), request)
    }

    function edit(title, body) {
        github.editIssue(plugin.repo, issue.number, {"title": title, "body": body})

        info.title = title
        info.body = body
        info = info
    }

    function comment(text) {
        github.newIssueComment(plugin.repo, issue, text)

        newComment(text)
    }

    Timer {
        interval: 2 * 60 * 1000 // 2 minutes
        running: true
        repeat: true
        onTriggered: load()
    }
}
