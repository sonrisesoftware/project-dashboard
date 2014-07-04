import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Struct {
    id: object

    _type: "ActionItem"

    property string text
    onTextChanged: _set("text", text)

    property string action
    onActionChanged: _set("action", action)

    property int click_count
    onClick_countChanged: _set("click_count", click_count)

    onCreated: {
        _set("text", text)
        _set("action", action)
        _set("click_count", click_count)
        _loaded = true
        _created = true
    }

    onLoaded: {
        text = _get("text", "")
        action = _get("action", "")
        click_count = _get("click_count", undefined)
    }

    _properties: ["_type", "_version", "text", "action", "click_count"]
}
