import QtQuick 2.0
import "../../udata"
import ".."

Document {
    id: object

    _id: "settings"
    _type: "Settings"

    property string uuid
    onUuidChanged: _set("uuid", uuid)

    onLoaded: {
        uuid = _get("uuid", undefined)
    }
}
