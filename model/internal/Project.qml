import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _type: "Project"

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
        _set("notificationsEnabled", notificationsEnabled)
        _set("name", name)
    }

    onLoaded: {
        notificationsEnabled = _get("notificationsEnabled", false)
        var list = _get("inbox", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            inbox.add(item)
        }
        name = _get("name", "")
        var list = _get("plugins", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            plugins.add(item)
        }
    }

    _properties: ["_type", "_version", "notificationsEnabled", "inbox", "name", "plugins"]
}
