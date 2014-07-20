import QtQuick 2.0
import "internal" as Internal

Internal.LaunchpadPlugin {
    id: plugin

    pluginView: launchpadPlugin
    configuration: "lp:" + name

    function setup() {
        app.prompt(i18n.tr("Launchpad"), i18n.tr("Enter the name of a Launchpad project:"), "Project name", "").done(function (name) {
            plugin.name = name
            refresh()
        })
    }

    onLoaded: refresh()

    function refresh() {
        var ticketsHandler = function (data, info) {
            var json = JSON.parse(data).entries
            //print("RESPONSE", data)

            var remaining = json.length
            var bugs = []

            for (var i = 0; i < json.length; i++) {
                var task = json[i]
                var promise = httpGet(json[i].bug_link).done(function(data, info) {
                    var found = false
                    var json = JSON.parse(data)
                    json.task = info.task
                    bugs.push(json)

                    remaining--

                    if (remaining == 0) {
                        issues.busy = true

                        for (var k = 0; k < bugs.length; k++) {
                            var bug = bugs[k]
                            for (var j = 0; j < issues.count; j++) {
                                var issue = issues.at(j)

                                if (issue.number === bug.id) {
                                    issue.info = bug
                                    found = true
                                    break
                                }
                            }

                            if (!found) {
                                var issue = _db.create('LaunchpadBug', {info: bug}, plugin)
                                issues.add(issue)
                            }
                        }

                        issues.busy = false
                    }
                })
                promise.info.task = task
            }
            //reloadComponents()

            print("LAUNCHPAD:", issues.count)
        }

        var promise = httpGet('/%1?ws.op=searchTasks'.arg(name)).done(ticketsHandler)
    }

    function getUser(link) {
        if (typeof(link) != "string") {
            return undefined
        } if (usersInfo && usersInfo.hasOwnProperty(link)) {
            /// Custom color for links
            var response = usersInfo[link]
            print("USER", JSON.stringify(response))
            return response
        } else {
            //print("Calling Markdown API")
            httpGet(link).done(function(data, info) {
                if (!usersInfo)
                    usersInfo = {}
                var json = JSON.parse(data)
                usersInfo[link] = {
                    'login': json.name,
                    'name': json.display_name,
                    'avatar_url': json.logo_link
                }
                usersInfo = usersInfo
            })
            return {"login": "unknown"}
        }
    }
}
