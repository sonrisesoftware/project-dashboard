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

    property string description: repo.description ? repo.description : ""

    property bool isFork: repo.fork ? repo.fork : false

    property string owner: name ? name.split('/', 1)[0] : ""

    property bool hasPushAccess: repo.permissions ? repo.permissions.push : false

    property int nextNumber: 1

    property var milestones: []
    property var availableAssignees: []

    property var components: []

    function reloadComponents() {
        var list = []

        for (var i = 0; i < issues.count; i++) {
            var issue = issues.get(i).modelData

            if (!issue.open)
                continue

            var title = issue.title

            if (title.match(/\[.*\].*/) !== null) {
                var index = title.indexOf(']')
                var component = title.substring(1, index)

                //print(title, component)

                if (list.indexOf(component) == -1) {
                    list.push(component)
                }
            }
        }

        components = list
    }

    function setup() {
        app.prompt(i18n.tr("GitHub"), i18n.tr("Enter the name of a GitHub repository:"), "user/repo", "").done(function (name) {
            plugin.name = name
            refresh()
        })
    }

    onLoaded: refresh()

    function refresh() {
        var handler = function(data) {
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
                    var issue = _db.create('Issue', {info: json[i]}, plugin)
                    issues.add(issue)
                    //issue.refresh(syncId)

                    nextNumber = Math.max(nextNumber, issue.number + 1)
                }
            }
            issues.busy = false

            reloadComponents()
        }


        httpGet('/repos/%1'.arg(name)).done(function (data) {
            repo = Utils.cherrypick(JSON.parse(data), ['name', 'full_name', 'description', 'fork', 'permissions'])
            print("RESPONSE:", JSON.stringify(repo))

            httpGet('/repos/%1/issues?state=all'.arg(name)).done(handler)
        })
    }

    function httpGet(call) {
        return githubPlugin.service.httpGet(call)
    }
}
