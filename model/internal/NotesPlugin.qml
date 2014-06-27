import QtQuick 2.0
import "../../udata"
import ".."

Plugin {
    id: object

    _type: "NotesPlugin"

    property DocumentListModel notes: DocumentListModel {
        type: "notes"
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
