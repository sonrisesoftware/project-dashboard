import QtQuick 2.0
import "../../udata"
import ".."

Document {
    id: object

    _id: "backend"
    _type: "Backend"

    property var markdownCache
    onMarkdownCacheChanged: _set("markdownCache", markdownCache)

    property ListModel projects: ListModel {
        function add(item) {
            _loaded = true
            item._parent = projects
            append({modelData: item})
        }

        onCountChanged: {
            if (!_loaded) return

            var list = []
            for (var i = 0; i < projects.count; i++) {
                var id = projects.get(i).modelData._id
                list.push(id)
            }
            _set("projects", list)
        }
    }

    onLoaded: {
        markdownCache = _get("markdownCache", {})
        var list = _get("projects", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            item._parent = projects
            projects.append({modelData: item})
        }
    }
}
