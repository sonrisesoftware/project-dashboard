import QtQuick 2.0
import Ubuntu.Components 0.1
import "../ubuntu-ui-extras/httplib.js" as Http

Object {
    id: queue

    property bool busy: count > 0 || list.length > 0
    property int count: 0

    property int totalCount: 0

    signal error(var call, var status, var response, var args)

    property var list: []
    property var groups: { return {} }
    property int nextGroup: 0

    property bool hasError: {
        for (var key in groups) {
            if (groups[key].errors.length > 0)
                return true
        }

        return false
    }

    function append(id, operation) {
        if (list === undefined)
            list = []
        list.push(operation)
        list = list
        totalCount++
        groups[id].count++
        groups[id].total++
    }

    function newGroup(title) {
        var id = nextGroup++
        ////print(title)
        groups[id] = {
            "title": title,
            "count": 0,
            "total": 0,
            "errors": []
        }
        groups = groups

        return id
    }

    function http(id, call, path, options, headers, body, args) {
        var operation = {
            "type": "http",
            "group": id,
            "data": {
                "path": path,
                "call": call,
                "options": options,
                "headers": headers,
                "body": body,
                "args": args
            }
        }

        append(id, operation)
    }

    function httpGet(id, path, options, headers, callback, args) {
        var operation = {
            "type": "httpGet",
            "group": id,
            "data": {
                "path": path,
                "options": options,
                "headers": headers,
                "callback": callback,
                "args": args
            }
        }

        append(id, operation)
    }

    function action(id, action, args) {
        var operation = {
            "type": "action",
            "group": id,
            "data": {
                "action": action,
                "args": args
            }
        }

        append(id, operation)
    }

    function doOperation(op) {
        ////print("Doing operation:", op.type)
        if (op.type === "http") {
            doHttp(op.group, op.data)
        } else if (op.type === "httpGet") {
            doHttpGet(op.group, op.data)
        } else {
            throw "Operation not supported: " + op.type
        }
    }

    function doHttpGet(id, data) {
        count++
        Http.request(data.path, "GET", data.options, function(has_error, status, response) {
            ////print("Finished", id)
            groups[id].count--
            groups = groups
            count--
            if (has_error) {
                groups[id].errors.push({
                                           "call": data.path,
                                           "status": status,
                                           "response": response
                                       })
                error(data.path, status, response, data.args)
            } else {
                if (data.callback)
                    data.callback(status, response, data.args)
            }

            if (groups[id].count === 0 && groups[id].errors.length === 0) {
                ////print("Deleting", id)
                delete groups[id]
                groups = groups
            }
        }, undefined, data.headers, undefined)
    }

    function doHttp(id, data) {
        count++
        Http.request(data.path, data.call, data.options, function(has_error, status, response) {
            groups[id].count--
            groups = groups
            count--
            if (has_error) {
                groups[id].errors.push({
                                           "call": data.path,
                                           "status": status,
                                           "response": response
                                       })
                error(data.path, status, response, data.args)
            }

            if (groups[id].count === 0 && groups[id].errors.length === 0) {
                delete groups[id]
                groups = groups
            }
        }, undefined, data.headers, data.body)
    }

    Timer {
        interval: 5
        repeat: true
        running: list.length > 0
        onTriggered: {
            var op = list[0]
            try {
                doOperation(op)
            } catch(e) {
                //print(e)
            }

            list.splice(0, 1)
            list = list
        }
    }
}
