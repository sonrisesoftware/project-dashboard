import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Struct {
    id: object

    _type: "Event"

    property string text
    onTextChanged: _set("text", text)

    property var date
    onDateChanged: _set("date", date === undefined ? undefined : date.toISOString())

    onCreated: {
        _set("text", text)
        _set("date", date === undefined ? undefined : date.toISOString())
        _loaded = true
        _created = true
    }

    onLoaded: {
        text = _get("text", "")
        date = _get("date", undefined) === undefined ? undefined : new Date(_get("date", undefined))
    }

    _properties: ["_type", "_version", "text", "date"]
}
