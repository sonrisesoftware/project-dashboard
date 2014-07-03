import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "NotesPlugin"

    property DocumentListModel notes: DocumentListModel {
        type: "notes"
    }

    onCreated: {
    }

    onLoaded: {
        var list = _get("notes", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            notes.add(item)
        }
    }

    _properties: ["_type", "_version", "notes"]
}
