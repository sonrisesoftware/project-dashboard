import QtQuick 2.0
import "../../udata"
import ".."

Service {
    id: object

    _type: "GitHub"

    property var repos
    onReposChanged: _set("repos", repos)

    property var user
    onUserChanged: _set("user", user)

    property string oauthToken
    onOauthTokenChanged: _set("oauthToken", oauthToken)

    onLoaded: {
        repos = _get("repos", [])
        user = _get("user", undefined)
        oauthToken = _get("oauthToken", "")
    }
}
