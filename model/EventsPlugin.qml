import QtQuick 2.0
import "internal" as Internal

Internal.EventsPlugin {
    pluginView: eventsPlugin

    function addEvent(text, date) {
        events.add(_db.create('Event', {text: text, date: date}, eventsPlugin))
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
