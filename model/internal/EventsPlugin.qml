import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "EventsPlugin"

    property DocumentListModel events: DocumentListModel {
        type: "events"
    }

    onCreated: {
        _loaded = true
        _created = true
    }

    onLoaded: {
        var list = _get("events", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            events.add(item)
        }
    }

    _properties: ["_type", "_version", "events"]
}
