import QtQuick 2.0
import "../qml-extras/httplib.js" as Http
import "../qml-air"

Object {
    property url url: "http://google.com"

    property bool connected: true

    Component.onCompleted: ping()

    Timer {
        interval: 60 * 1000 //
        repeat: true
        running: true

        onTriggered: ping()
    }

    function ping() {
        Http.get(url, undefined, function(has_error, status, response) {
            connected = !has_error
        })
    }
}
