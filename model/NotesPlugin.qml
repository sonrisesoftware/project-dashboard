import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
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
            onTriggered: PopupUtils.open(newNotePage)
        }

        pulseItem: PulseItem {
            show: notes.count > 0
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

                    onClicked: pageStack.push(notePage, {note: note})

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
                                value: "<font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date_created)) + "</font>"

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

                                    onClicked: pageStack.push(notePage, {note: modelData})
                                }
                            }
                        }
                    }
                }
            }

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

            ActionButton {
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    margins: units.gu(1.5)
                }

                iconName: "pencil"
                onClicked: PopupUtils.open(newNotePage)
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
}
