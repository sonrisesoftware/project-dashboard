import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _id: "settings"
    _type: "Settings"

    property string uuid
    onUuidChanged: _set("uuid", uuid)

    onCreated: {
        _set("uuid", uuid)
    }

    onLoaded: {
        uuid = _get("uuid", undefined)
    }

    _properties: ["_type", "_version", "uuid"]
}
