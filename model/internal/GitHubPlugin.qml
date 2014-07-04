import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "GitHubPlugin"

    property string repo: ""
    onRepoChanged: _set("repo", repo)

    property DocumentListModel issues: DocumentListModel {
        type: "issues"
    }

    property var repoInfo:  {}
    onRepoInfoChanged: _set("repoInfo", repoInfo)

    onCreated: {
        _set("repo", repo)
        _set("repoInfo", repoInfo)
        _loaded = true
        _created = true
    }

    onLoaded: {
        repo = _get("repo")
        var list = _get("issues", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            issues.add(item)
        }
        repoInfo = _get("repoInfo")
    }

    _properties: ["_type", "_version", "repo", "issues", "repoInfo"]
}
