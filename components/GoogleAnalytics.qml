import QtQuick 2.0
import Ubuntu.Components 0.1
import "../ubuntu-ui-extras/httplib.js" as Http

Object {
    property string trackingID: ""
    property string clientID: ""
    property string appName: ""
    property string appVersion: ""

    property string __api: "http://www.google-analytics.com/collect"

    function visitScreen(screen) {
        print("Visiting screen:", screen)
        Http.post(__api, [
                      "v=1",
                      "tid=" + trackingID,
                      "cid=" + clientID,
                      "t=appview",
                      "an=" + appName,
                      "av=" + appVersion,
                      "cd=" + screen
                  ])
    }

    function eventTriggered(category, event) {
        Http.post(__api, [
                      "v=1",
                      "tid=" + trackingID,
                      "cid=" + clientID,
                      "t=event",
                      "an=" + appName,
                      "av=" + appVersion,
                      "ec=" + category,
                      "ea=" + event
                  ])
    }

    function error(type, is_fatal) {
        Http.post(__api, [
                      "v=1",
                      "tid=" + trackingID,
                      "cid=" + clientID,
                      "t=exception",
                      "an=" + appName,
                      "av=" + appVersion,
                      "exd=" + type,
                      "exf=" + (is_fatal ? 1 : 0)
                  ])
    }

    function generateID() {
        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000)
                   .toString(16)
                   .substring(1);
        }

        return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
               s4() + '-' + s4() + s4() + s4();
    }
}
