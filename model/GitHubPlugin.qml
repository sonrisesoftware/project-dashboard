import QtQuick 2.0
import "internal" as Internal

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
        httpGet('/repos/%1'.arg(repo)).done(function (data) {
            repoInfo = JSON.parse(data)
        })
    }

    function httpGet(call) {
        return Http.get(api + call,{
                            options: ["access_token=" + oauthToken],
                            headers: {"Accept":"application/vnd.github.v3+json"}
                        })
    }
}
