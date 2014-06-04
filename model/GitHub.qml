import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import "internal" as Internal

import "../qml-extras/httplib.js" as Http
import "../qml-extras/utils.js" as Utils

Internal.GitHub {
    type: "GitHub"
    icon: "github"
    title: i18n.tr("GitHub")
    authenticationStatus: user ? i18n.tr("Logged in as %1").arg(user.login) : ""
    enabled: oauthToken !== ""

    description: i18n.tr("GitHub is the best place to share code with friends, co-workers, classmates, and complete strangers. Over six million people use GitHub to build amazing things together.")

    accountItem: ListItem.Subtitled {
        iconSource: user.avatar_url
        text: user.name
        subText: user.login
        visible: oauth !== ""
        progression: true
        height: visible ? units.gu(8) : 0
    }

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
