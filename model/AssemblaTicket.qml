import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/dateutils.js" as DateUtils

Ticket {
    id: issue

    _type: "AssemblaTicket"

    typeRegular: issue.isPullRequest ? "merge request" : "ticket"
    typeCap: issue.isPullRequest ? "Merge request" : "Ticket"
    typeTitle: issue.isPullRequest ? "Merge Request" : "Ticket"

    number: info.number

    open: info.state === 1
    assignee: info.assigned_to_id ? parent.getUser(info.assigned_to_id) : undefined

    summary: {
        var text = i18n.tr("%1 opened this issue %2").arg(issue.author.login).arg(DateUtils.friendlyTime(issue.created_at))

        return text
    }

    state: info.status === "Accepted" ? "In Progress" : info.status

    milestone: parent.getMilestone(info.milestone_id)
    title: info.summary
    tags: []//info.tags
    author: parent.getUser(info.reporter_id)
    created_at: info.created_on
    body: info.description

    property var allEvents: {
        var list = []
        comments.forEach(function(comment) {
            var user = parent.getUser(comment.user_id)
            var created_at = comment.created_on

            var body = comment.comment ? comment.comment : ""

            if (comment.ticket_changes) {
                var array = parseEvent(comment.ticket_changes)

                array.forEach(function(item) {
                    if (item.event === 'assigned_to_id') {
                        body += "\n\n* Assigned to <b>%1</b>".arg(item.to)
                    } else if (item.event === 'status') {
                        body += "\n\n* Changed status to <b>%1</b>".arg(item.to)
                    }
                })
            }

            body = body.trim()

            if (body !== "")
                list.push({
                              "user":user,
                              "body": body,
                              "created_at": created_at
                          })
        })

        list.sort(function (a, b) {
            return new Date(a.created_at) - new Date(b.created_at)
        })

        var i = 0
        while (i < list.length - 1) {
            if (!DateUtils.datesEqual(new Date(list[i].created_at), new Date(list[i + 1].created_at)) &&
                    list[i].hasOwnProperty("actor") && list[i + 1].hasOwnProperty("actor")) {
                list.splice(i + 1, 0, {"event": "-", "actor": "", "created_at": ""})
                i++
            }

            i++
        }

        return list
    }

    function refresh() {

    }

    function load() {
        ready = true

        parent.httpGet('/spaces/%1/tickets/%2/ticket_comments.json'.arg(parent.name).arg(issue.number)).done(function (data, info) {
            comments = JSON.parse(data)
            print(data)
        })
    }

    function parseEvent(string) {
        var array = string.split('\n')
        var events = []

        for (var i = 0; i < array.length; i++) {
            var item = array[i]
            if (item.indexOf("- - ") == 0) {
                var type = item.substring(4)
                print('Type:', type, item)
                var first = array[i + 1].substring(4)
                if (array.length > i + 2 && array[i + 2].indexOf('  - ') == 0) {
                    var second = array[i + 2].substring(4)
                    print('2  ', first, second)
                    events.push({
                                    event: type,
                                    from: first,
                                    to: second
                                })
                    i += 2
                } else {
                    print('1  ', first)
                    events.push({
                                    event: type,
                                    to: first
                                })
                    i += 1
                }
            }
        }

        return events
    }
}
