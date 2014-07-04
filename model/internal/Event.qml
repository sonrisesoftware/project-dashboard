import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _type: "Event"

    property var date: undefined
    onDateChanged: _set("date", date === undefined ? undefined : date.toISOString())

    property string text: ""
    onTextChanged: _set("text", text)

    onCreated: {
        _set("date", date === undefined ? undefined : date.toISOString())
        _set("text", text)
        _loaded = true
        _created = true
    }

    onLoaded: {
        date = _get("date") === undefined ? undefined : new Date(_get("date"))
        text = _get("text")
    }

    _properties: ["_type", "_version", "date", "text"]
}
