import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Struct {
    id: object

    _type: "Issue"

    property var info
    onInfoChanged: _set("info", info)

    onCreated: {
        _set("info", info)
        _loaded = true
        _created = true
    }

    onLoaded: {
        info = _get("info", undefined)
    }

    _properties: ["_type", "_version", "info"]
}
