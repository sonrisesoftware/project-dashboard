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

    onLoaded: {
        if (oauthToken !== "") {
            httpCachedGet('/user').done(function(data, info) {
                if (info.status !== 304) {
                    user = Utils.cherrypick(JSON.parse(data), ['name', 'login', 'avatar_url'])
                    httpDone('user', info)
                }
            })

            httpCachedGet('/user/repos').done(function(data, info) {
                if (info.status !== 304) {
                    var list = JSON.parse(data)
                    repos = Utils.cherrypick(list, ['full_name', 'description'])
                    httpDone('repos', info)
                }
            })
        }
    }

    function httpCachedGet(call, options) {
        if (cacheInfo && cacheInfo[call]) {
            if (!options) options = []
            if (!options.headers) options.headers = {}

            options.headers['If-None-Match'] = cacheInfo[call]
        }

        print(JSON.stringify(cacheInfo))

        return httpGet(call, options).then(function (data, info) {
            httpDone(call, info)
            return data
        })
    }

    function httpDone(id, info) {
        if (!cacheInfo)
            cacheInfo = {}
        cacheInfo[id] = info.headers['etag']
        cacheInfo = cacheInfo

        app.rateLimit = info.headers['x-ratelimit-remaining'] + '/' + info.headers['x-ratelimit-limit']
    }

    function httpGet(call, options) {
        if (!options)
            options = {}
        if (!options.options)
            options.options = []
        if (!options.headers)
            options.headers = {}

        options.headers['Accept'] = "application/vnd.github.v3+json"

        if (call.indexOf('http') !== 0) {
            call = api + call
            options.options.push("access_token="+oauthToken)
        }

        return Http.get(call, options).error(function (data, info) {
            print('GITHUB ERROR:', info.status, info.headers['x-ratelimit-remaining'])
            print(data)
        })
    }

    function httpPost(call, options) {
        if (!options)
            options = {}
        if (!options.options)
            options.options = []
        if (!options.headers)
            options.headers = {}

        options.headers['Accept'] = "application/vnd.github.v3+json"

        if (call.indexOf('http') !== 0) {
            call = api + call
            options.options.push("access_token="+oauthToken)
        }

        return Http.post(call, options).error(function (data, info) {
            print('GITHUB ERROR:', info.status, info.headers['x-ratelimit-remaining'])
            print(data)
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
}
