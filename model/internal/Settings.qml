import QtQuick 2.0
import "../../udata"
import ".."

Document {
    id: object

    _id: "settings"
    _type: "Settings"

    property string uuid
    onUuidChanged: _set("uuid", uuid)

    property var markdownCache
    onMarkdownCacheChanged: _set("markdownCache", markdownCache)

    onLoaded: {
        uuid = _get("uuid", "")
        markdownCache = _get("markdownCache", {})
    }
}
