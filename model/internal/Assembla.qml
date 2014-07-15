import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Service {
    id: object

    _id: "assembla"
    _created: true
    _type: "Assembla"

    property string refreshToken
    onRefreshTokenChanged: _set("refreshToken", refreshToken)

    property var repos: []
    onReposChanged: _set("repos", repos)

    property string oauthToken
    onOauthTokenChanged: _set("oauthToken", oauthToken)

    property var user: undefined
    onUserChanged: _set("user", user)

    onCreated: {
        _set("refreshToken", refreshToken)
        _set("repos", repos)
        _set("oauthToken", oauthToken)
        _set("user", user)
        _loaded = true
        _created = true
    }

    onLoaded: {
        refreshToken = _get("refreshToken", "")
        repos = _get("repos", [])
        oauthToken = _get("oauthToken", "")
        user = _get("user", undefined)
    }

    _properties: ["_type", "_version", "refreshToken", "repos", "oauthToken", "user"]
}
