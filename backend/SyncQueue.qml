import QtQuick 2.0
import Ubuntu.Components 0.1
import "../ubuntu-ui-extras/httplib.js" as Http

Object {
    id: queue

    property bool busy: count > 0
    property alias count: list.count

    signal error(var status, var response, var args)

    ListModel {
        id: list
    }

    function http(call, path, options, headers, body, args) {
        var operation = {
            "type": "http",
            "data": {
                "path": path,
                "call": call,
                "options": options,
                "headers": headers,
                "body": body,
                "args": args
            }
        }

        list.append(operation)
    }

    function httpGet(call, path, options, headers, callback, args) {
        var operation = {
            "type": "httpGet",
            "data": {
                "path": path,
                "call": call,
                "options": options,
                "headers": headers,
                "callback": callback,
                "args": args
            }
        }

        list.append(operation)
    }

    function action(action, args) {
        var operation = {
            "type": "action",
            "data": {
                "action": action,
                "args": args
            }
        }

        list.append(operation)
    }

    function doOperation(op) {
        if (op.type === "http") {
            doHttp(op.data)
        } else {
            throw "Operation not supported: " + op.type
        }
    }

    function doHttp(data) {
        Http.request(data.path, data.call, data.options, function(has_error, status, response) {
            if (has_error) {
                error(status, response, data.args)
            }
        }, undefined, data.headers, data.body)
    }

    Timer {
        interval: 5
        repeat: true
        running: list.count > 0
        onTriggered: {
            var op = list.get(0)
            doOperation(op)
            list.remove(0)
        }
    }
}
