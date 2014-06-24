import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _type: "Note"

    property var date_created
    onDate_createdChanged: _set("date_created", date_created === undefined ? undefined : date_created.toUTCString())

    property string contents
    onContentsChanged: _set("contents", contents)

    property string title
    onTitleChanged: _set("title", title)

    onCreated: {
        _set("date_created", date_created === undefined ? undefined : date_created.toUTCString())
        _set("contents", contents)
        _set("title", title)
    }

    onLoaded: {
        date_created = _get("date_created", undefined) === undefined ? undefined : new Date(_get("date_created", undefined))
        contents = _get("contents", "")
        title = _get("title", "")
    }

    _properties: ["_type", "_version", "date_created", "contents", "title"]
}
