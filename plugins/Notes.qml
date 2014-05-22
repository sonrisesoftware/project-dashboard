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

    name: "notes"
    title: "Notes"
    icon: "pencil-square-o"

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
            text: i18n.tr("Add Note")
            description: i18n.tr("Add a new note to your project")
            iconSource: getIcon("add")
            onTriggered: PopupUtils.open(newNotePage)
        }

        pulseItem: PulseItem {
            show: false//notes.length > 0
            title: i18n.tr("Recent Notes")
            viewAll: i18n.tr("View all <b>%1</b> notes").arg(notes.length)

            ListItem.Standard {
                text: i18n.tr("No notes")
                enabled: false
                visible: notes.length === 0
                height: visible ? implicitHeight : 0
            }

            Repeater {
                model: Math.min(notes.length, project.maxRecent)
                delegate: SubtitledListItem {
                    property var modelData: notes[index]
                    id: item
                    text: escapeHTML(modelData.title) + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"
                    subText: modelData.contents

                    onClicked: pageStack.push(notePage, {index: index})

                    removable: true
                    backgroundIndicator: ListItemBackground {
                        state: item.swipingState
                        iconSource: getIcon("delete-white")
                        text: i18n.tr("Delete")
                    }
                    onItemRemoved: {
                        notes.splice(index, 1)
                        notes = notes
                    }
                }
            }
        }

        page: PluginPage {
            title: i18n.tr("Notes")

            actions: Action {
                text: i18n.tr("Add")
                iconSource: getIcon("add")
                onTriggered: PopupUtils.open(newNotePage)
            }

            Flickable {
                id: listView
                anchors.fill: parent
                clip: true

                contentWidth: width
                contentHeight: column.contentHeight + units.gu(2)

                Item {
                    width: listView.width
                    height: column.contentHeight + units.gu(2)
                    ColumnFlow {
                        id: column
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: units.gu(1)
                        }
                        repeaterCompleted: true
                        columns: extraWideAspect ? 3 : wideAspect ? 2 : 1

                        onVisibleChanged: {
                            column.repeaterCompleted = true
                            column.reEvalColumns()
                        }

                        Timer {
                            interval: 10
                            running: true
                            onTriggered: {
                                //print("Triggered!")
                                column.repeaterCompleted = true
                                column.reEvalColumns()
                            }
                        }

                        Repeater {
                            model: notes

                            onCountChanged: {
                                column.reEvalColumns()
                            }

                            delegate: GridTile {
                                title: modelData.title
                                value: "<font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"

                                ListItem.Empty {
                                    height: _desc.height + units.gu(4)
                                    Label {
                                        id: _desc
                                        anchors {
                                            verticalCenter: parent.verticalCenter
                                            left: parent.left
                                            right: parent.right
                                            margins: units.gu(2)
                                        }
                                        text: modelData.contents
                                        maximumLineCount: 5
                                        elide: Text.ElideRight
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    }

                                    showDivider: false

                                    onClicked: pageStack.push(notePage, {index: index})
                                }
                            }
                        }
                    }
                }
            }

//            ListView {
//                id: listView
//                anchors.fill: parent
//                model: notes
//                delegate: SubtitledListItem {
//                    id: item
//                    text: escapeHTML(modelData.title) + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"
//                    subText: modelData.contents

//                    onClicked: pageStack.push(notePage, {index: index})

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
//                }
//            }

            Scrollbar {
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

    Component {
        id: newNotePage

        ComposerSheet {
            id: sheet

            title: i18n.tr("New Note")
            contentsHeight: wideAspect ? units.gu(40) : mainView.height

            onConfirmClicked: newNote(nameField.text, descriptionField.text)

            Component.onCompleted: {
                sheet.__leftButton.text = i18n.tr("Cancel")
                sheet.__leftButton.color = "gray"
                sheet.__rightButton.text = i18n.tr("Create")
                sheet.__rightButton.color = sheet.__rightButton.__styleInstance.defaultColor
                sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../ubuntu-ui-extras/SuruSheetStyle.qml"), sheet)
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

            tools: ToolbarItems {
                opened: wideAspect
                locked: wideAspect

                onLockedChanged: opened = locked

                ToolbarButton {
                    text: i18n.tr("Delete")
                    iconSource: getIcon("delete")

                    onTriggered: {
                        pageStack.pop()
                        notes.splice(page.index, 1)
                        notes = notes
                    }
                }
            }
        }
    }

    function escapeHTML(html) {
        return html.replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;").replace(/"/g, "&quot;");
    }
}
