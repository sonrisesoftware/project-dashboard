import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/dateutils.js" as DateUtils

Issue {
    id: issue

    _type: "AssemblaTicket"

    typeRegular: issue.isPullRequest ? "merge request" : "ticket"
    typeCap: issue.isPullRequest ? "Merge request" : "Ticket"
    typeTitle: issue.isPullRequest ? "Merge Request" : "Ticket"

    number: info.number

    isPullRequest: false
    merged: isPullRequest ? pull && pull.merged  ? pull.merged : false
                                        : false
    mergeable: isPullRequest ? pull && pull.mergeable ? pull.mergeable : false
                                           : false
    open: info.state === 1
    assignee: parent.getUser(info.assigned_to_id)

    property bool assignedToMe: {
        return issue.assignee.login == assemblaPlugin.service.user.login
    }

    property bool hasAssignee: {
        var result = issue.assignee && issue.assignee.length > 0
        print("ASSIGNEE:", assignee)
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

    milestone: parent.getMilestone(info.milestone_id)
    title: info.summary
    labels: []//info.tags
    user: parent.getUser(info.reporter_id)
    created_at: info.created_on
    body: info.description

    function renderBody() {
        return body
    }

    property var allEvents: {
        var list = []
        comments.forEach(function(comment) {

            if (comment.ticket_changes) {
                var array = parseEvent(comment.ticket_changes)

                array.forEach(function(item) {
                    if (item.event === 'assigned_to_id') {
                        list.push({
                                      "event": "assigned",
                                      "actor": parent.getUser(item.to),
                                      "created_at": comment.created_on
                                  })
                    } else if (item.event === 'status') {
                        list.push({
                                      "event": "status",
                                      "status": item.to,
                                      "created_at": comment.created_on
                                  })
                    }
                })
            }

            if (comment.comment) {
                list.push({
                              "user": parent.getUser(comment.user_id),
                              "body": comment.comment,
                              "created_at": comment.created_on
                          })
            }
        })

        list.sort(function (a, b) {
            return new Date(a.created_at) - new Date(b.created_at)
        })

        var i = 0
        while (i < list.length - 1) {
            if (!DateUtils.datesEqual(new Date(list[i].created_at), new Date(list[i + 1].created_at))) {
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

        plugin.httpGet('/spaces/%1/tickets/%2/ticket_comments.json'.arg(plugin.name).arg(issue.number)).done(function (data, info) {
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
