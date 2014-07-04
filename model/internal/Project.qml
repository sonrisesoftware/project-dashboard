import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _type: "Project"

    property bool starred: true
    onStarredChanged: _set("starred", starred)

    property bool notificationsEnabled
    onNotificationsEnabledChanged: _set("notificationsEnabled", notificationsEnabled)

    property DocumentListModel inbox: DocumentListModel {
        type: "inbox"
    }

    property string name
    onNameChanged: _set("name", name)

    property DocumentListModel plugins: DocumentListModel {
        type: "plugins"
    }

    onCreated: {
        _set("starred", starred)
        _set("notificationsEnabled", notificationsEnabled)
        _set("name", name)
        _loaded = true
        _created = true
    }

    onLoaded: {
        starred = _get("starred", true)
        notificationsEnabled = _get("notificationsEnabled", false)
        inbox.load()
        name = _get("name", "")
        plugins.load()
    }

    _properties: ["_type", "_version", "starred", "notificationsEnabled", "inbox", "name", "plugins"]
}
