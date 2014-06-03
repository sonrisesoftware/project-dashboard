import QtQuick 2.0
import "../../udata"
import ".."

Plugin {
    id: object

    _type: "NotesPlugin"

    property ListModel notes: ListModel {
        function add(item) {
            _loaded = true
            item._parent = notes
            append({modelData: item})
        }

        onCountChanged: {
            if (!_loaded) return

            var list = []
            for (var i = 0; i < notes.count; i++) {
                var id = notes.get(i).modelData._id
                list.push(id)
            }
            _set("notes", list)
        }
    }

    onLoaded: {
        var list = _get("notes", [])
        for (var i = 0; i < list.length; i++) {
            var item = _db.load(list[i], object)
            item._parent = notes
            notes.append({modelData: item})
        }
    }
}
