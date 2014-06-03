import QtQuick 2.0
import Ubuntu.Components 1.1
import "internal" as Internal

import "../qml-extras/httplib.js" as Http
import "../qml-extras/utils.js" as Utils

Internal.GitHub {
    type: "GitHub"
    icon: "github"
    title: i18n.tr("GitHub")
    authenticationStatus: user ? i18n.tr("Logged in as %1").arg(user.login) : ""
    enabled: oauthToken !== ""

    property string api: "https://api.github.com"

    onOauthTokenChanged: {
        if (oauthToken !== "") {
            httpGet('/user').done(function(data) {
                user = JSON.parse(data)
            })

            httpGet('/repos').done(function(data) {
                list = JSON.parse(data)
                repos = Utils.cherrypick(list, [""])
            })
        }
    }

    function httpGet(call) {
        return Http.get(api + call,["access_token=" + oauthToken],
                        undefined, {"Accept":"application/vnd.github.v3+json"})
    }

    function revoke() {
        oauthToken = ""
        user = undefined
        repos = []
    }

    function authenticate() {
        pageStack.push(Qt.resolvedUrl("../backend/services/OAuthPage.qml"))
    }
}
