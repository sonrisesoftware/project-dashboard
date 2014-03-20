import QtQuick 2.0
import Ubuntu.Components 0.1
import "../ubuntu-ui-extras/httplib.js" as Http

Object {
    id: queue

    property bool busy: count > 0 || list.length > 0
    property int count: 0

    signal error(var status, var response, var args)

    property var list: []

    function append(operation) {
        if (list === undefined)
            list = []
        list.push(operation)
        list = list
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

        append(operation)
    }

    function httpGet(path, options, headers, callback, args) {
        var operation = {
            "type": "httpGet",
            "data": {
                "path": path,
                "options": options,
                "headers": headers,
                "callback": callback,
                "args": args
            }
        }

        append(operation)
    }

    function action(action, args) {
        var operation = {
            "type": "action",
            "data": {
                "action": action,
                "args": args
            }
        }

        append(operation)
    }

    function doOperation(op) {
        //print("Doing operation:", op.type)
        if (op.type === "http") {
            doHttp(op.data)
        } else if (op.type === "httpGet") {
            doHttpGet(op.data)
        } else {
            throw "Operation not supported: " + op.type
        }
    }

    function doHttpGet(data) {
        count++
        Http.request(data.path, "GET", data.options, function(has_error, status, response) {
            count--
            if (has_error) {
                error(status, response, data.args)
            } else {
                //print("RESPONSE:", JSON.parse(response).length)
                if (data.callback)
                    data.callback(response, data.args)
            }
        }, undefined, data.headers, undefined)
    }

    function doHttp(data) {
        count++
        Http.request(data.path, data.call, data.options, function(has_error, status, response) {
            count--
            if (has_error) {
                error(status, response, data.args)
            }
        }, undefined, data.headers, data.body)
    }

    Timer {
        interval: 5
        repeat: true
        running: list.length > 0
        onTriggered: {
            var op = list[0]
            doOperation(op)
            list.splice(0, 1)
            list = list
        }
    }
}
