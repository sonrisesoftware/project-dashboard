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
import "notes"
import "../ui"
import "../components"
import "../ubuntu-ui-extras"
import "../model"
import "."

PluginView {
    id: notesPlugin

    type: "Notes"
    title: i18n.tr("Notes")
    icon: "pencil-square-o"

    items: [
        PluginItem {
            title: i18n.tr("Notes")
            icon: "pencil-square-o"
            pulseItem: NotesPulseItem {}

            page: NotesPage {}



            Component {
                id: notePage

                Page {
                    id: page
                    title: note.title

                    property Note note

                    TextArea {
                        id: descriptionField
                        placeholderText: i18n.tr("Contents")
                        color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                        text: note.contents

                        onTextChanged: note.contents = text

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            margins: units.gu(2)
                        }
                    }

                    tools: ToolbarItems {

                        ToolbarButton {
                            text: i18n.tr("Delete")
                            iconSource: getIcon("delete")

                            onTriggered: {
                                pageStack.pop()
                                note.remove()
                            }
                        }
                    }
                }
            }
        }

    ]
}
