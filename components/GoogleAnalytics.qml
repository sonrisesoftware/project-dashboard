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
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
            return v.toString(16);
        });
    }
}
