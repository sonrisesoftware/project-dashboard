import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/utils.js" as Utils
import "../qml-extras/listutils.js" as List

Internal.GitHubPlugin {
    id: plugin

    pluginView: githubPlugin

    property var assignedIssues: List.filter(issues, function(issue) {
        return issue.assignedToMe && issue.open
    })

    property var openIssues: List.filter(issues, function(issue) {
        return issue.open
    })

    property string api: "https://api.github.com"

    property string description: repo ? repo.description : ""

    property bool isFork: repo ? repo.fork : false

    property string owner: name ? name.split('/', 1) : ""

    property int nextNumber: 1

    onCreated: {
        name = "iBeliever/test"
        refresh()
    }

    onLoaded: refresh()

    function refresh() {
        var handler = function(data) {
            var json = JSON.parse(data)

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
                    var issue = _db.create('Issue', {info: json[i]}, plugin)
                    issues.add(issue)
                    //issue.refresh(syncId)

                    nextNumber = Math.max(nextNumber, issue.number + 1)
                }
            }
        }


        httpGet('/repos/%1'.arg(name)).done(function (data) {
            repo = Utils.cherrypick(JSON.parse(data), ['name', 'full_name', 'description', 'fork'])
            print("RESPONSE:", JSON.stringify(repo))

            httpGet('/repos/%1/issues?state=all'.arg(name)).done(handler)
        })
    }

    function httpGet(call) {
        return githubPlugin.service.httpGet(call)
    }
}
