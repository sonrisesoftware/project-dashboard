import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Service {
    id: object

    _id: "github"
    _created: true
    _type: "GitHub"

    property var repos: []
    onReposChanged: _set("repos", repos)

    property var user: undefined
    onUserChanged: _set("user", user)

    property string oauthToken
    onOauthTokenChanged: _set("oauthToken", oauthToken)

    onCreated: {
        _set("repos", repos)
        _set("user", user)
        _set("oauthToken", oauthToken)
        _loaded = true
        _created = true
    }

    onLoaded: {
        repos = _get("repos", [])
        user = _get("user", undefined)
        oauthToken = _get("oauthToken", "")
    }

    _properties: ["_type", "_version", "repos", "user", "oauthToken"]
}
