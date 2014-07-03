import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem

import "internal" as Internal
import "../components"
import "../plugins"
import "../ubuntu-ui-extras"
import "../qml-extras/utils.js" as Utils

Internal.NotesPlugin {
    id: plugin

    pluginView: notesPlugin

    function newNote(title, contents) {
        var note = _db.create('Note', {title: title, contents: contents, date_created: new Date()}, plugin)
        notes.add(note)

        return note
    }
}
