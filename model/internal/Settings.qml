import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _id: "settings"
    _created: true
    _type: "Settings"

    property string uuid: undefined
    onUuidChanged: _set("uuid", uuid)

    onCreated: {
        _set("uuid", uuid)
        _loaded = true
        _created = true
    }

    onLoaded: {
        uuid = _get("uuid", undefined)
    }

    _properties: ["_type", "_version", "uuid"]
}
