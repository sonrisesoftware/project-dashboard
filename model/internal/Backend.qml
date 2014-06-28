import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Document {
    id: object

    _id: "backend"
    _type: "Backend"

    property var markdownCache: {}
    onMarkdownCacheChanged: _set("markdownCache", markdownCache)

    property DocumentListModel projects: DocumentListModel {
        type: "projects"
    }

    onCreated: {
        _set("markdownCache", markdownCache)
    }

    onLoaded: {
        markdownCache = _get("markdownCache")
        var list = _get("projects", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            item._parent = projects
            projects.append({modelData: item})
        }
    }

    _properties: ["_type", "_version", "markdownCache", "projects"]
}
