import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _id: "backend"
    _created: true
    _type: "Backend"

    property var markdownCache: {}
    onMarkdownCacheChanged: _set("markdownCache", markdownCache)

    property DocumentListModel projects: DocumentListModel {
        type: "projects"
    }

    onCreated: {
        _set("markdownCache", markdownCache)
        _loaded = true
        _created = true
    }

    onLoaded: {
        var start = new Date()
        markdownCache = _get("markdownCache", {})
        projects.load()
        var end = new Date()

        print("Loaded in ", (end-start)/1000, 'seconds')
    }

    _properties: ["_type", "_version", "markdownCache", "projects"]
}
