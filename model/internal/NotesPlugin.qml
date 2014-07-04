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
        _loaded = true
        _created = true
    }

    onLoaded: {
        notes.load()
    }

    _properties: ["_type", "_version", "notes"]
}
