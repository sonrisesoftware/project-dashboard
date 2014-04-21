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
import "../backend"
import "../components"

import "../qml-extras/listutils.js" as List
import "../qml-extras/dateutils.js" as DateUtils
import "../qml-air"
import "../qml-air/ListItems" as ListItem

Plugin {
    id: plugin

    name: "notes"

    property var notes: doc.get("notes", [])

    onSave: {
        doc.set("notes", notes)
    }

    function newNote(title, contents) {
        notes = [{"title": title, "contents": contents, "date": new Date().toJSON()}].concat(notes)
        notes = notes
        notification.show(i18n.tr("Note created"))
    }

    items: PluginItem {
        title: i18n.tr("Notes")
        icon: "pencil-square-o"
        value: notes.length > 0 ? notes.length : ""

        action: Action {
            name: i18n.tr("Add Note")
            description: i18n.tr("Add a new note to your project")
            iconName: "plus"
            onTriggered: newNotePage.open()
        }

        pulseItem: PulseItem {
            show: false//notes.length > 0
            title: i18n.tr("Recent Notes")
            viewAll: i18n.tr("View all <b>%1</b> notes").arg(notes.length)

            ListItem.Standard {
                text: i18n.tr("No notes")
                enabled: false
                visible: notes.length === 0
                height: visible ? units.gu(6) : 0
            }

            Repeater {
                model: Math.min(notes.length, project.maxRecent)
                delegate: SubtitledListItem {
                    property var modelData: notes[index]
                    id: item
                    text: escapeHTML(modelData.title) + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"
                    subText: modelData.contents
                    height: units.gu(6)

                    onClicked: pageStack.push(notePage, {index: index})

//                    removable: true
//                    backgroundIndicator: ListItemBackground {
//                        state: item.swipingState
//                        iconSource: getIcon("delete-white")
//                        text: i18n.tr("Delete")
//                    }
//                    onItemRemoved: {
//                        notes.splice(index, 1)
//                        notes = notes
//                    }
                }
            }
        }

        page: PluginPage {
            title: i18n.tr("Notes")

            leftWidgets: Button {
                text: i18n.tr("Add")
                onClicked: newNotePage.open()
            }

            ListView {
                id: listView
                anchors.fill: parent
                model: notes
                delegate: SubtitledListItem {
                    id: item
                    text: escapeHTML(modelData.title) + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"
                    subText: modelData.contents
                    height: units.gu(6)

                    onClicked: pageStack.push(notePage, {index: index})

//                    removable: true
//                    backgroundIndicator: ListItemBackground {
//                        state: item.swipingState
//                        iconSource: getIcon("delete-white")
//                        text: i18n.tr("Delete")
//                    }

//                    onItemRemoved: {
//                        notes.splice(index, 1)
//                        notes = notes
//                    }
                }
            }

            ScrollBar {
                flickableItem: listView
            }

            Label {
                anchors.centerIn: parent
                visible: notes.length === 0
                text: "No notes"
                opacity: 0.5
                fontSize: "large"
            }
        }
    }

    Sheet {
        id: newNotePage

        title: i18n.tr("New Note")

        onAccepted: newNote(nameField.text, descriptionField.text)

        Component.onCompleted: {
            newNotePage.__leftButton.text = i18n.tr("Cancel")
            newNotePage.__rightButton.text = i18n.tr("Create")
        }

        TextField {
            id: nameField
            placeholderText: i18n.tr("Title")
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            Keys.onTabPressed: descriptionField.forceActiveFocus()
        }

        TextArea {
            id: descriptionField
            placeholderText: i18n.tr("Contents")

            anchors {
                left: parent.left
                right: parent.right
                top: nameField.bottom
                bottom: parent.bottom
                topMargin: units.gu(2)
            }
        }
    }

    Component {
        id: notePage

        Page {
            id: page
            title: note.title

            property int index: 0
            property var note: notes[index]

            Component.onDestruction: {
                notes[index].contents = descriptionField.text
                notes = notes
            }

            TextArea {
                id: descriptionField
                placeholderText: i18n.tr("Contents")
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                text: note.contents

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    margins: units.gu(2)
                }
            }

            rightWidgets: Button {
                text: i18n.tr("Delete")
                iconName: "trash"

                onClicked: {
                    pageStack.pop()
                    notes.splice(page.index, 1)
                    notes = notes
                }
            }
        }
    }

    function escapeHTML(html) {
        return html.replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;").replace(/"/g, "&quot;");
    }
}
