import QtQuick 2.0
import "../../udata"
import ".."

Document {
    id: object

    _type: "Project"

    property ListModel inbox: ListModel {
        function add(item) {
            _loaded = true
            item._parent = inbox
            append({modelData: item})
        }

        onCountChanged: {
            if (!_loaded) return

            var list = []
            for (var i = 0; i < inbox.count; i++) {
                var id = inbox.get(i).modelData._id
                list.push(id)
            }
            _set("inbox", list)
        }
    }

    property string name
    onNameChanged: _set("name", name)

    property ListModel plugins: ListModel {
        function add(item) {
            _loaded = true
            item._parent = plugins
            append({modelData: item})
        }

        onCountChanged: {
            if (!_loaded) return

            var list = []
            for (var i = 0; i < plugins.count; i++) {
                var id = plugins.get(i).modelData._id
                list.push(id)
            }
            _set("plugins", list)
        }
    }

    onLoaded: {
        var list = _get("inbox", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            item._parent = inbox
            inbox.append({modelData: item})
        }
        name = _get("name", "")
        var list = _get("plugins", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            item._parent = plugins
            plugins.append({modelData: item})
        }
    }
}
