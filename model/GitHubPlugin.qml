import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/utils.js" as Utils
import "../qml-extras/listutils.js" as List

Internal.GitHubPlugin {
    id: plugin

    pluginView: githubPlugin

    property string api: "https://api.github.com"

    property string description: repo.description ? repo.description : ""

    property bool isFork: repo.fork ? repo.fork : false

    property string owner: name ? name.split('/', 1)[0] : ""

    property bool hasPushAccess: repo.permissions ? repo.permissions.push : false


    function getUserName(id) {
        return id.login
    }

    function reloadComponents() {
        var list = []

        for (var i = 0; i < issues.count; i++) {
            var issue = issues.get(i).modelData

            if (!issue.open)
                continue

            var title = issue.title

            if (title.match(/\[.*\].*/) !== null) {
                var index = title.indexOf(']')
                var component = title.substring(1, index)

                //print(title, component)

                if (list.indexOf(component) == -1) {
                    list.push(component)
                }
            }
        }

        components = list
    }

    function setup() {
        app.prompt(i18n.tr("GitHub"), i18n.tr("Enter the name of a GitHub repository:"), "user/repo", "").done(function (name) {
            plugin.name = name
            refresh()
        })
    }

    function newIssue(title, description) {
        var number = nextNumber++
        var json = {
            "state": "open",
            "number": number,
            "title": title,
            "body": description,
            "user": githubPlugin.service.user,
            "labels": [],
            "created_at": new Date().toJSON()
        }

        var issue = _db.create('Issue', {info: json}, plugin)
        issues.add(issue)
        app.toast(i18n.tr("Issue created"))
        httpPost('/repos/%1/issues'.arg(name), {
                     body: JSON.stringify({ "title": title, "body": description })
                 })
    }

    onLoaded: refresh()

    function refresh() {
        var handler = function(data, info) {
            if (info.status === 304) {
                reloadComponents()
                return
            }

            var json = JSON.parse(data)

            issues.busy = true
            for (var i = 0; i < json.length; i++) {
                var found = false
                for (var j = 0; j < issues.count; j++) {
                    var issue = issues.at(j)

                    if (issue.number === json[i].number) {
                        issue.info = json[i]
                        found = true
                        break
                    }
                }

                if (!found) {
                    var issue = _db.create('Issue', {info: json[i]}, plugin)
                    issues.add(issue)
                    //issue.refresh(syncId)
                }
            }
            issues.busy = false

            //print('Headers', JSON.stringify(info.headers))

            var links = parse_link_header(info.headers['link'])

            if (links.next) {
                httpGet(links.next).done(handler)
            } else {
                reloadComponents()
            }
        }


        httpGet('/repos/%1'.arg(name)).done(function (data, info) {
            if (info.status !== 304) {
                repo = Utils.cherrypick(JSON.parse(data), ['name', 'full_name', 'description', 'fork', 'permissions'])
                print("RESPONSE:", JSON.stringify(repo))
            }

            if (!isFork)
                httpGet('/repos/%1/issues?state=all'.arg(name)).done(handler)
        })

        httpGet('/repos/%1/assignees'.arg(name)).done(function (data, info) {
            if (info.status !== 304) {
                availableAssignees = Utils.cherrypick(JSON.parse(data), ['login'])
            }
        })

        httpGet('/repos/%1/milestones'.arg(name)).done(function (data, info) {
            if (info.status !== 304) {
                milestones = Utils.cherrypick(JSON.parse(data), ['number', 'state', 'title', 'description', 'creator', 'due_on'])
            }
        })

        httpGet('/repos/%1/pulls?state=all'.arg(name)).done(handler)
    }

    function httpPost(call, options) {
        return githubPlugin.service.httpPost(call, options)
    }

    function httpGet(call, options) {
        if (cacheInfo && cacheInfo[call]) {
            if (!options) options = []
            if (!options.headers) options.headers = {}

            options.headers['If-None-Match'] = cacheInfo[call]
        }

        return githubPlugin.service.httpGet(call, options).then(function(data, info) {
            httpDone(call, info)
            return data
        })
    }

    function httpDone(id, info) {
        if (!cacheInfo)
            cacheInfo = {}
        cacheInfo[id] = info.headers['etag']
        cacheInfo = cacheInfo
    }

    /*
    * parse_link_header()
    *
    * Parse the Github Link HTTP header used for pageination
    * http://developer.github.com/v3/#pagination
    */
    function parse_link_header(header) {
        if (!header || header.length === 0) {
            return {}
        }

        // Split parts by comma
        var parts = header.split(',');
        var links = {};
        // Parse each part into a named link
        parts.forEach(function(p) {
            var section = p.split(';');
            if (section.length != 2) {
                throw "section could not be split on ';'"
            }
            var url = section[0].replace(/<(.*)>/, '$1').trim();
            var name = section[1].replace(/rel="(.*)"/, '$1').trim();
            links[name] = url;
        });

        return links;
    }
}
