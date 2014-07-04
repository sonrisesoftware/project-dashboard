import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "internal" as Internal

import "../components"

import "../qml-extras/httplib.js" as Http
import "../qml-extras/utils.js" as Utils

Internal.GitHub {
    id: github

    authenticationStatus: user ? i18n.tr("Logged in as %1").arg(user.login) : ""
    enabled: oauthToken !== ""

    description: i18n.tr("GitHub is the best place to share code with friends, co-workers, classmates, and complete strangers. Over six million people use GitHub to build amazing things together.")

    accountItem: SubtitledListItem {
        iconSource: user ? user.avatar_url : ""
        text: user ? user.name : enabled ? i18n.tr("Loading user info...") : ""
        subText: user ? user.login : ""
        visible: github.enabled
        progression: true
        height: visible ? units.gu(8) : 0
    }

    property string api: "https://api.github.com"

    onOauthTokenChanged: {
        if (oauthToken !== "") {
            httpGet('/user').done(function(data) {
                user = Utils.cherrypick(JSON.parse(data), ['name', 'login', 'avatar_url'])
            })

            httpGet('/user/repos').done(function(data) {
                var list = JSON.parse(data)
                repos = Utils.cherrypick(list, ['full_name', 'description'])
            })
        }
    }

    function httpGet(call) {
        return Http.get(api + call,{
                            options: ["access_token=" + oauthToken],
                            headers: {"Accept":"application/vnd.github.v3+json"}
                        })
    }

    function revoke() {
        oauthToken = ""
        user = undefined
        repos = []
    }

    function authenticate() {
        pageStack.push(Qt.resolvedUrl("../backend/services/OAuthPage.qml"), {github: github})
    }

    function createProject() {
        PopupUtils.open(Qt.resolvedUrl("../ui/AddGitHubProjectPage.qml"), app, {github: github})
    }



    function addGitHubProject(name) {
        app.prompt(i18n.tr("Add GitHub Project"),
                   i18n.tr("Enter the name for your project connected to %1:").arg(name),
                   i18n.tr("Project Name"),
                   name).done(function (name) {
                       var project = backend.addProject(name)
                       //pageStack.push(Qt.resolvedUrl("ProjectPage.qml"), {project: project})
                       app.toast(i18n.tr("Project created"))
                   })
    }
}
