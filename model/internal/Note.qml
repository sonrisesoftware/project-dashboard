import QtQuick 2.0
import "../../udata"
import ".."

Document {
    id: object

    _type: "Note"

    property var date_created
    onDate_createdChanged: _set("date_created", date_created)

    property string contents
    onContentsChanged: _set("contents", contents)

    property string title
    onTitleChanged: _set("title", title)

    onLoaded: {
        date_created = _get("date_created", undefined)
        contents = _get("contents", "")
        title = _get("title", "")
    }
}
