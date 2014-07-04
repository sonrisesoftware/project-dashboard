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
        events.load()
    }

    _properties: ["_type", "_version", "events"]
}
