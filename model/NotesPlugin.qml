import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

import "internal" as Internal
import "../components"
import "../ubuntu-ui-extras"
import "../qml-extras/utils.js" as Utils

Internal.NotesPlugin {
    id: plugin
    icon: "pencil-square-o"
    title: i18n.tr("Notes")

    function newNote(title, contents) {
        var note = _db.create('Note', {title: title, contents: contents, date_created: new Date()}, plugin)
        notes.add(note)

        return note
    }

    items: PluginItem {
        title: i18n.tr("Notes")
        icon: "pencil-square-o"

        value: notes.length > 0 ? notes.length : ""

        action: Action {
            text: i18n.tr("Add Note")
            description: i18n.tr("Add a new note to your project")
            iconSource: getIcon("add")
            onTriggered: newNote('Sample Note', 'Dummy contents here!')
        }

        pulseItem: PulseItem {
            show: false//notes.length > 0
            title: i18n.tr("Recent Notes")
            viewAll: i18n.tr("View all <b>%1</b> notes").arg(notes.count)

            ListItem.Standard {
                text: i18n.tr("No notes")
                enabled: false
                visible: notes.length === 0
                height: visible ? implicitHeight : 0
            }

            Repeater {
                model: Math.min(notes.count, 3)// project.maxRecent)
                delegate: SubtitledListItem {
                    id: item

                    property Note note: notes.at(index)

                    text: Utils.escapeHTML(note.title) + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(note.date_created)) + "</font>"
                    subText: note.contents

                    removable: true
                    backgroundIndicator: ListItemBackground {
                        state: item.swipingState
                        iconSource: getIcon("delete-white")
                        text: i18n.tr("Delete")
                    }
                    onItemRemoved: {
                        note.remove()
                    }
                }
            }
        }
    }
}
