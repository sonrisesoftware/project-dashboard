import QtQuick 2.0
import "internal" as Internal

Internal.LaunchpadPlugin {
    id: plugin

    pluginView: launchpadPlugin

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
            print("RESPONSE", data)

            for (var i = 0; i < json.length; i++) {
                var task = json[i]
                httpGet(json[i].bug_link).done(function(data, info) {
                    var found = false
                    var json = JSON.parse(data)
                    json.task = task

                    for (var j = 0; j < issues.count; j++) {
                        var issue = issues.at(j)

                        if (issue.number === json.id) {
                            issue.info = json
                            found = true
                            break
                        }
                    }

                    if (!found) {
                        var issue = _db.create('LaunchpadBug', {info: json}, plugin)
                        issues.add(issue)
                    }
                })
            }
            //reloadComponents()

            print("LAUNCHPAD:", issues.count)
        }

        var promise = httpGet('/%1?ws.op=searchTasks'.arg(name)).done(ticketsHandler)
    }

    function getUser(id) {
        var list = id.split('/')
        return {"login": list[list.length - 1]}
    }
}
