import QtQuick 2.0
import Ubuntu.Components 0.1
import "../../ubuntu-ui-extras"
import "../../backend/utils.js" as Utils

Object {
    id: issue

    property var info: doc.get("info", {})
    property var pull: doc.get("pull", {})
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
    property bool merged: isPullRequest ? pull.merged : false
    property bool mergeable: isPullRequest ? pull.mergeable : false
    property bool open: info.state === "open"
    property var assignee: info.assignee
    property var milestone: info.milestone
    property string title: info.title
    property var labels: info.labels
    property var user: info.user
    property var created_at: info.created_at
    property string body: typeof(info.body) == "string" ? info.body : ""
    property string status: doc.get("status", "")

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
        doc.set("events", events)
    }

    function newComment(text) {
        comments.push({body: text, user: github.user, date: new Date().toISOString()})
        doc.set("comments", comments)
    }

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

    Component.onCompleted: {
        if (isPullRequest) {
            loading++
            github.get(info._links.statuses.href, function(has_error, status, response) {
                                 print(response)
                                 if (JSON.parse(response)[0] === undefined) {
                                     doc.set("status", "")
                                 } else {
                                     doc.set("status", JSON.parse(response)[0].state)
                                 }

                                 loading--
                             })
        }
    }

    function load() {
        print("LOADING>>>>>>>>>")
        loaded = true

        if (isPullRequest) {
            loading += 2
            github.getPullRequest(plugin.repo, number, function(has_error, status, response) {
                loading--
                doc.set("pull", JSON.parse(response))
                print("MERGED:", JSON.parse(response).merged, pull.merged)
                print("MERGEABLE:", JSON.parse(response).mergeable, pull.mergeable)
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
        if (issue.milestone && issue.milestone.hasOwnProperty("number") && milestone && issue.milestone.number === milestone.number)
            return

        if (!(issue.milestone && issue.milestone.hasOwnProperty("number")) && !milestone)
            return

        var request = github.editIssue(plugin.repo, issue.number, {"milestone": milestone.number}, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to change milestone. Check your connection and/or firewall settings."))
            } else {
                info.milestone = milestone
                doc.set("info", info)
            }
        })

        if (milestone === undefined)
            busy(i18n.tr("Changing Milestone"), i18n.tr("Removing milestone from the %1").arg(type), request)
        else
            busy(i18n.tr("Changing Milestone"), i18n.tr("Setting milestone to <b>%1</b>").arg(milestone.title), request)
    }

    function setAssignee(assignee) {
        var login = assignee ? assignee.login : ""

        if (issue.assignee && issue.assignee.hasOwnProperty("login") && issue.assignee.login === login)
            return

        if (!(issue.assignee && issue.assignee.hasOwnProperty("login")) && login === "")
            return

        var request = github.editIssue(plugin.repo, issue.number, {"assignee": login}, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to change assignee. Check your connection and/or firewall settings."))
            } else {
                if (login !== "") {
                    info.assignee = assignee
                    doc.set("info", info)
                    newEvent("assigned", assignee)
                } else {
                    info.assignee = undefined
                    doc.set("info", info)
                }
            }
        })

        if (login) {
            busy(i18n.tr("Changing Assignee"), i18n.tr("Setting assignee to <b>%1</b>").arg(login), request)
        } else {
            busy(i18n.tr("Changing Assignee"), i18n.tr("Removing assignee from %1").arg(type), request)
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

        var request = github.editIssue(plugin.repo, issue.number, {"title": title, "body": body}, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to update issue. Check your connection and/or firewall settings."))
            } else {
                info.title = title
                info.body = body
                doc.set("info", info)
            }
        })

        busy(i18n.tr("Updating Issue"), i18n.tr("Updating the title and body of the issue"), request)
    }

    function comment(text) {
        var request = github.newIssueComment(plugin.repo, issue, text, function(response) {
            complete()
            if (response === -1) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to create comment. Check your connection and/or firewall settings."))
            } else {
                newComment(text)
            }
        })

        busy(i18n.tr("Creating Comment"), i18n.tr("Creating a new comment for issue <b>%1</b>").arg(issue.number), request)
    }
}
