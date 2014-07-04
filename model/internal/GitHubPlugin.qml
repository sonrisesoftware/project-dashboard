import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "GitHubPlugin"

    property var repo: undefined
    onRepoChanged: _set("repo", repo)

    property string name: ""
    onNameChanged: _set("name", name)

    property DocumentListModel issues: DocumentListModel {
        type: "issues"
    }

    onCreated: {
        _set("repo", repo)
        _set("name", name)
        _loaded = true
        _created = true
    }

    onLoaded: {
        repo = _get("repo")
        name = _get("name")
        var list = _get("issues", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            issues.add(item)
        }
    }

    _properties: ["_type", "_version", "repo", "name", "issues"]
}
