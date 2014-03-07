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
import "../backend"
import "../components"
import "../ubuntu-ui-extras/listutils.js" as List
import "../ubuntu-ui-extras/dateutils.js" as DateUtils
import "../ubuntu-ui-extras"

Plugin {
    id: plugin

    title: i18n.tr("Notes")
    iconSource: "pencil-square-o"

    viewAllMessage: i18n.tr("View all notes")

    property alias notes: doc.children

    property int nextDocId: doc.get("nextDocId", 0)

    function newNote(title, contents) {
        var docId = String(nextDocId)
        doc.set("nextDocId", nextDocId + 1)
        doc.newDoc(docId, {"title": title, "contents": contents, "date": new Date().toJSON()})
        //print(JSON.stringify(doc.save()))
        return docId
    }

    action: Action {
        text: i18n.tr("Add")
        onTriggered: pageStack.push(newNotePage)
    }

    document: Document {
        id: doc
        docId: "notes"
        parent: project.document
    }

    ListItem.Header {
        text: "Recent Notes"
        visible: notes.length > 0
    }

    Repeater {
        model: Math.min(notes.length, 4)
        delegate: SubtitledListItem {
            id: item
            text: note.get("title") + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(note.get("date"))) + "</font>"
            subText: note.get("contents")



            //onClicked: pageStack.push(Qt.resolvedUrl("resources/WebPage.qml"), {resource: modelData})
            //onPressAndHold: PopupUtils.open(actionsPopover, item, {index: documents.length - index - 1})

            Document {
                id: note
                docId: notes[notes.length - index - 1]
                parent: doc
            }
        }
    }

    ListItem.Standard {
        enabled: false
        visible: notes.length === 0
        text: "No notes"
    }

    Component {
        id: newNotePage

        Page {
            title: i18n.tr("New Note")

            TextField {
                id: nameField
                placeholderText: i18n.tr("Title")
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                    margins: units.gu(2)
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
                    margins: units.gu(2)
                }
            }

            tools: ToolbarItems {
                locked: true
                opened: true

                back: ToolbarButton {
                    text: i18n.tr("Cancel")
                    iconSource: getIcon("back")

                    onTriggered: {
                        pageStack.pop()
                    }
                }

                ToolbarButton {
                    text: i18n.tr("Save")
                    iconSource: getIcon("add")

                    onTriggered: {
                        pageStack.pop()
                        newNote(nameField.text, descriptionField.text)
                    }
                }
            }
        }
    }
}
