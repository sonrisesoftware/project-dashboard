/*
 * Project Dashboard - Manage everything about your projects in one app
 * Copyright (C) 2014 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../../components"
import "../../qml-extras/listutils.js" as List
import "../../ubuntu-ui-extras"
import "../../model"
import "../../qml-extras/utils.js" as Utils

PulseItem {
    id: pulseItem

    show: List.length(notes) > 0
    title: i18n.tr("Recent Notes")

    viewAll: plugin ? i18n.tr("View all <b>%1</b> notes").arg(List.length(notes)) : ""

    property var notes: {
        if (plugin) {
            return plugin.notes
        } else {
            var notes = []

            for (var i = 0; i < backend.projects.count; i++) {
                var project = backend.projects.at(i)
                var p = project.getPlugin('Notes')

                if (p) {
                    notes = notes.concat(List.toList(p.notes))
                }
            }


            notes = notes.sort(function (a, b) {
                return new Date(b.date_created) - new Date(a.date_created)
            })

            return notes
        }
    }

    ListItem.Standard {
        text: i18n.tr("No notes")
        enabled: false
        visible: List.length(notes) === 0
        height: visible ? implicitHeight : 0
    }

    Repeater {
        id: repeater
        model: Math.min(List.length(notes), 3)// project.maxRecent)
        delegate: SubtitledListItem {
            id: item

            property Note note: List.getItem(notes, index)

            text: Utils.escapeHTML(note.title) + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(note.date_created)) + "</font>"
            subText: plugin ? note.contents : note.parent.parent.name

            onClicked: pageStack.push(notePage, {note: note})

            removable: true
            showDivider: index < repeater.count - 1 || showFooter
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
