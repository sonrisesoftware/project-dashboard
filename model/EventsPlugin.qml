import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/listutils.js" as List
import "../qml-extras/dateutils.js" as DateUtils

Internal.EventsPlugin {
    id: plugin
    pluginView: eventsPlugin

    property var upcomingEvents: List.filter(events, function(event) {
        return DateUtils.dateIsThisWeek(event.date)
    })

    function addEvent(text, date) {
        events.add(_db.create('Event', {text: text, date: date}, plugin))
    }

    onLoaded: {
        var i = 0
        while (i < events.count) {
            if (events.at(i).expired)
                events.remove()
            else
                i++
        }
    }
}
