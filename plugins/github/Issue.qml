import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../ubuntu-ui-extras"

Object {
    id: issue

    property var info: doc.get("info", {})
    property var events: doc.get("events", [])
    property var comments: doc.get("comments", [])
    property var commits: doc.get("commits", [])

    property int number
    Document {
        id: doc
        docId: String(number)
        parent: plugin.issues
    }

    property int loading

    property bool isPullRequest: info.hasOwnProperty("head") //TODO: Is this the best way to handle it?
    property bool merged: isPullRequest ? info.merged : false
    property bool mergeable: isPullRequest ? info.mergeable : false
    property bool open: info.state === "open"
    property var milestone: info.milestone
    property string title: info.title
    property var labels: info.labels
    property var user: info.user
    property var created_at: info.created_at
    property string body: info.hasOwnProperty("body") ? info.body : ""

    function renderBody() {
        return renderMarkdown(body, plugin.repo)
    }

    signal error(var title, var message)
    signal busy(var title, var message, var request)
    signal complete()

    property bool loaded

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

    function load() {
        print("LOADING>>>>>>>>>")
        loaded = true

        if (isPullRequest) {
            loading += 2
            github.getPullRequest(plugin.repo, number, function(has_error, status, response) {
                loading--
                doc.set("info", Utils.mergeObject(info, JSON.parse(response)))
            })

            github.getPullCommits(plugin.repo, issue, function(has_error, status, response) {
                loading--
                doc.set("commits", JSON.parse(response))
            })
        }

        loading += 2
        github.getIssueComments(plugin.repo, issue, function(has_error, status, response) {
            loading--
            doc.set("comments", JSON.parse(response))
        })

        github.getIssueEvents(plugin.repo, issue, function(has_error, status, response) {
            loading--
            doc.set("events", JSON.parse(response))
        })
    }

    function closeOrReopen() {
        if (open) {
            var request = github.editIssue(plugin.repo, number, {"state": "closed"}, function(response) {
                complete()
                if (response === -1) {
                    error(i18n.tr("Connection Error"), i18n.tr("Unable to close %1. Check your connection and/or firewall settings.").arg(type))
                } else {
                    info.state = "closed"
                    doc.set("info", info)
                }
            })

            busy(i18n.tr("Closing %1").arg(typeCap),
                 i18n.tr("Closing %2 <b>#%1</b>").arg(number).arg(type),
                 request)
        } else {
            var request = github.editIssue(plugin.repo, number, {"state": "open"}, function(response) {
                complete()
                if (response === -1) {
                    error(i18n.tr("Connection Error"), i18n.tr("Unable to reopen %1. Check your connection and/or firewall settings.").arg(type))
                } else {
                    info.state = "open"
                    doc.set("info", info)
                }
            })

            busy(i18n.tr("Reopening %1").arg(typeCap),
                 i18n.tr("Reopening %2 <b>#%1</b>").arg(number).arg(type),
                 request)
        }
    }

    function setMilestone(milestone) {
        if (issue.milestone && issue.milestone.hasOwnProperty("number") && issue.milestone.number === milestone.number)
            return

        if (!(issue.milestone && issue.milestone.hasOwnProperty("number")) && milestone.number === undefined)
            return

        var request = github.editIssue(plugin.repo, issue.number, {"milestone": number}, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to change milestone. Check your connection and/or firewall settings."))
            } else {
                info.milestone = {"number": number}
                doc.set("info", info)
            }
        })

        if (milestone === undefined)
            busy(i18n.tr("Changing Milestone"), i18n.tr("Removing milestone from the %1").arg(type), request)
        else
            busy(i18n.tr("Changing Milestone"), i18n.tr("Setting milestone to <b>%1</b>").arg(milestone.title), request)
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

        var request = github.editIssue(plugin.repo, issue.number, {"title": title, "body": body}, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to edit. Check your connection and/or firewall settings."))
            } else {
                info.title = title
                info.body = body
                doc.set("info", info)
            }
        })

        busy(i18n.tr("Changing Labels"), i18n.tr("Changes the labels for the issue"), request)
    }

    function comment(text) {
        var request = github.newIssueComment(plugin.repo, issue, text, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to create comment. Check your connection and/or firewall settings."))
            } else {
                comments.push({body: text, user: {login: github.user}, created_at: new Date().toISOString()})
                doc.set("comments", comments)
            }
        })

        busy(i18n.tr("Creating Comment"), i18n.tr("Creating a new comment for issue <b>%1</b>").arg(issue.number), request)
    }
}
