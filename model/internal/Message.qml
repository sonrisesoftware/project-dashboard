import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Struct {
    id: object

    _type: "Message"

    property string icon
    onIconChanged: _set("icon", icon)

    property string title
    onTitleChanged: _set("title", title)

    onCreated: {
        _set("icon", icon)
        _set("title", title)
        _loaded = true
        _created = true
    }

    onLoaded: {
        icon = _get("icon", "")
        title = _get("title", "")
    }

    _properties: ["_type", "_version", "icon", "title"]
}
