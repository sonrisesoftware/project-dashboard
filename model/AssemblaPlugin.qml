import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/utils.js" as Utils
import "../qml-extras/listutils.js" as List

Internal.AssemblaPlugin {
    id: plugin

    pluginView: assemblaPlugin

    property var assignedIssues: List.filter(issues, function(issue) {
        return issue.assignedToMe && issue.open && !issue.isPullRequest
    })

    property var openIssues: List.filter(issues, function(issue) {
        return issue.open && !issue.isPullRequest
    })

    property var openPulls: List.filter(issues, function(issue) {
        return issue.open && issue.isPullRequest
    })

    property bool hasPushAccess: false

    property int nextNumber: 1

    function setup() {
        app.prompt(i18n.tr("Assembla"), i18n.tr("Enter the name of an Assembla space:"), "Space name", "").done(function (name) {
            plugin.name = name
            refresh()
        })
    }

    onLoaded: refresh()

    function refresh() {
        var ticketsHandler = function (data, info) {
            var json = JSON.parse(data)

            issues.busy = true
            for (var i = 0; i < json.length; i++) {
                var found = false
                for (var j = 0; j < issues.count; j++) {
                    var issue = issues.at(j)

                    if (issue.number === json[i].number) {
                        issue.info = json[i]
                        found = true
                        break
                    }
                }

                if (!found) {
                    var issue = _db.create('AssemblaTicket', {info: json[i]}, plugin)
                    issues.add(issue)
                }
            }
            issues.busy = false

            print("ASSEMBLA:", issues.count)

            var promise = httpGet('/spaces/%1/tickets.json?report=0&per_page=50&page=%2'.arg(name).arg(info.page + 1)).done(ticketsHandler)
            promise.info.page = info.page + 1
        }

        var promise = httpGet('/spaces/%1/tickets.json?report=0&per_page=50'.arg(name)).done(ticketsHandler)
        promise.info.page = 1

        var milestonesHandler = function (data, info) {
            var json = JSON.parse(data)

            if (info.page == 1) {
                milestones = json
            } else {
                milestones = milestones.concat(json)
            }

            var promise = httpGet('/spaces/%1/milestones/all.json?&per_page=50&page=%2'.arg(name).arg(info.page + 1)).done(milestonesHandler)
            promise.info.page = info.page + 1
        }

        promise = httpGet('/spaces/%1/milestones/all.json?&per_page=50'.arg(name)).done(milestonesHandler)
        promise.info.page = 1

        httpGet('/spaces/%1/user_roles.json'.arg(name)).done(function (data) {
            print("USER ROLES:", data)
            availableAssignees = JSON.parse(data)
        })
    }

    function getMilestone(id) {
        for (var i = 0; i < milestones.length; i++) {
            if (milestones[i].id === id)
                return milestones[i]
        }

        return undefined
    }

    function getUser(id) {
        if (typeof(id) != "string") {
            return ""
        } if (usersInfo && usersInfo.hasOwnProperty(id)) {
            return usersInfo[id]
        } else {
            httpGet("/users/%1.json".arg(id)).done(function(response, info) {
                if (!usersInfo)
                    usersInfo = {}
                usersInfo[id] = JSON.parse(response)
                usersInfo = usersInfo
            })
            print("Calling", id)
            return {"login":"unknown"}
        }
    }

    function httpGet(call) {
        return assemblaPlugin.service.httpGet(call)
    }
}
