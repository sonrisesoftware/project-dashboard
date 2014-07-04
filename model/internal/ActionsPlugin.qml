import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "ActionsPlugin"

    property DocumentListModel actions: DocumentListModel {
        type: "actions"
    }

    onCreated: {
        _loaded = true
        _created = true
    }

    onLoaded: {
        actions.load()
    }

    _properties: ["_type", "_version", "actions"]
}
