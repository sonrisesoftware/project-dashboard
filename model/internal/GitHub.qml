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

    property string oauthToken
    onOauthTokenChanged: _set("oauthToken", oauthToken)

    property var user: undefined
    onUserChanged: _set("user", user)

    property var cacheInfo: {}
    onCacheInfoChanged: _set("cacheInfo", cacheInfo)

    onCreated: {
        _set("repos", repos)
        _set("oauthToken", oauthToken)
        _set("user", user)
        _set("cacheInfo", cacheInfo)
        _loaded = true
        _created = true
    }

    onLoaded: {
        repos = _get("repos", [])
        oauthToken = _get("oauthToken", "")
        user = _get("user", undefined)
        cacheInfo = _get("cacheInfo", {})
    }

    _properties: ["_type", "_version", "repos", "oauthToken", "user", "cacheInfo"]
}
