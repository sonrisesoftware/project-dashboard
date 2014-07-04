import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _type: "Note"

    property var date_created: undefined
    onDate_createdChanged: _set("date_created", date_created === undefined ? undefined : date_created.toISOString())

    property string contents: ""
    onContentsChanged: _set("contents", contents)

    property string title: ""
    onTitleChanged: _set("title", title)

    onCreated: {
        _set("date_created", date_created === undefined ? undefined : date_created.toISOString())
        _set("contents", contents)
        _set("title", title)
        _loaded = true
        _created = true
    }

    onLoaded: {
        date_created = _get("date_created") === undefined ? undefined : new Date(_get("date_created"))
        contents = _get("contents")
        title = _get("title")
    }

    _properties: ["_type", "_version", "date_created", "contents", "title"]
}
