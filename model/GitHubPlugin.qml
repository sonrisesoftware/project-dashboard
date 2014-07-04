import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/utils.js" as Utils

Internal.GitHubPlugin {
    pluginView: githubPlugin

    property var assignedIssues: issues

    property string api: "https://api.github.com"

    onCreated: {
        repo = "iBeliever/test"
        refresh()
    }

    onLoaded: refresh()

    function refresh() {
        print("REFRESHING")
        httpGet('/repos/%1'.arg(repo)).done(function (data) {
            repoInfo = Utils.cherrypick(JSON.parse(data), ['name', 'full_name', 'description', 'fork'])
            print("RESPONSE:", JSON.stringify(repoInfo))
        })
    }

    function httpGet(call) {
        return githubPlugin.service.httpGet(call)
    }
}
