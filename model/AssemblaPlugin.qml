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

            var promise = httpGet('/spaces/%1/milestones/upcoming.json?&per_page=50&page=%2'.arg(name).arg(info.page + 1)).done(milestonesHandler)
            promise.info.page = info.page + 1
        }

        promise = httpGet('/spaces/%1/milestones/upcoming.json?&per_page=50'.arg(name)).done(milestonesHandler)
        promise.info.page = 1

        httpGet('/spaces/%1/users.json'.arg(name)).done(function (data) {
            print("USER ROLES:", data)
            availableAssignees = JSON.parse(data)

            //availableAssignees.forEach(function (user) {
                //availableAssignees[i].avatar_url = pluginView.service.api + '/users' + user.id + '/picture'
                //                httpGet('http://www.google.fr/images/srpr/logo3w.png').done(function (picture, info) {
//                    for (var i = 0; i < availableAssignees.length; i++) {
//                        if (availableAssignees[i].login === user.login) {
//                            print('Saving avatar for', user.login)
//                            print("Length", info.headers["content-length"], picture.length)
//                            picture = base64Encode(picture)

//                            availableAssignees[i].avatar_url = "data:" + info.headers["content-type"] + ";base64,"+ picture
//                            availableAssignees = availableAssignees
//                            return
//                        }
//                    }
//                })
            //})
            //availableAssignees = availableAssignees
        })
    }

    function base64Encode(str) {
        var CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        var out = "", i = 0, len = str.length, c1, c2, c3;
        while (i < len) {
            c1 = str.charCodeAt(i++) & 0xff;
            if (i == len) {
                out += CHARS.charAt(c1 >> 2);
                out += CHARS.charAt((c1 & 0x3) << 4);
                out += "==";
                break;
            }
            c2 = str.charCodeAt(i++);
            if (i == len) {
                out += CHARS.charAt(c1 >> 2);
                out += CHARS.charAt(((c1 & 0x3)<< 4) | ((c2 & 0xF0) >> 4));
                out += CHARS.charAt((c2 & 0xF) << 2);
                out += "=";
                break;
            }
            c3 = str.charCodeAt(i++);
            out += CHARS.charAt(c1 >> 2);
            out += CHARS.charAt(((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4));
            out += CHARS.charAt(((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6));
            out += CHARS.charAt(c3 & 0x3F);
        }
        return out;
    }

    function getMilestone(id) {
        for (var i = 0; i < milestones.length; i++) {
            if (milestones[i].id === id) {
                print(JSON.stringify(milestones[i]))
                return milestones[i]
            }
        }

        return undefined
    }

    function getUser(id) {
        for (var i = 0; i < availableAssignees.length; i++) {
            if (availableAssignees[i].id == id)
                return availableAssignees[i]
        }

        return {"login": "unknown"}
    }

    function httpGet(call) {
        return assemblaPlugin.service.httpGet(call)
    }
}
