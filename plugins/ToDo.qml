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

    name: "tasks"

    property var tasks: doc.get("tasks", [])

    onSave: {
        doc.set("tasks", tasks)
    }

    function newTask(title, contents) {
        tasks.push({"title": title, "contents": contents, "date": new Date().toJSON()})
        tasks = tasks
    }

    items: PluginItem {
        title: i18n.tr("Tasks")
        icon: "check-square-o"
        value: tasks.length > 0 ? tasks.length : ""

        action: Action {
            text: i18n.tr("Add Task")
            description: i18n.tr("Add a new task to your to do list")
            iconSource: getIcon("add")
            onTriggered: PopupUtils.open(newTaskPage)
        }

        pulseItem: PulseItem {

            visible: tasks.length > 0
            title: i18n.tr("Upcoming Tasks")
            viewAll: i18n.tr("View all <b>%1</b> tasks").arg(tasks.length)

            ListItem.Standard {
                text: i18n.tr("No tasks")
                enabled: false
                visible: tasks.length === 0
                height: visible ? implicitHeight : 0
            }

            Repeater {
                model: Math.min(tasks.length, project.maxRecent)
                delegate: SubtitledListItem {
                    property var modelData: tasks[tasks.length - index - 1]
                    id: item
                    text: modelData.title + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"
                    subText: modelData.contents

                    onClicked: pageStack.push(notePage, {index: index})

                    onItemRemoved: {
                        tasks.splice(index, 1)
                        tasks = tasks
                    }
                }
            }
        }

        page: PluginPage {
            title: i18n.tr("Tasks")

            actions: Action {
                text: i18n.tr("Add")
                iconSource: getIcon("add")
                onTriggered: PopupUtils.open(newTaskPage)
            }

            ListView {
                id: listView
                anchors.fill: parent
                model: tasks
                delegate: SubtitledListItem {
                    id: item
                    text: modelData.title + " <font color=\"" + colors["green"] + "\">" + Qt.formatDate(new Date(modelData.date)) + "</font>"
                    subText: modelData.contents

                    onClicked: pageStack.push(notePage, {index: index})

                    removable: true
                    backgroundIndicator: ListItemBackground {
                        state: item.swipingState
                        iconSource: getIcon("delete-white")
                        text: i18n.tr("Delete")
                    }

                    onItemRemoved: {
                        tasks.splice(index, 1)
                        tasks = tasks
                    }
                }
            }

            Scrollbar {
                flickableItem: listView
            }

            Label {
                anchors.centerIn: parent
                visible: tasks.length === 0
                text: "No tasks"
                opacity: 0.5
                fontSize: "large"
            }
        }
    }

    Component {
        id: newTaskPage

        ComposerSheet {
            id: sheet

            title: i18n.tr("New Task")
            contentsHeight: wideAspect ? units.gu(40) : mainView.height

            onConfirmClicked: newTask(nameField.text, descriptionField.text)

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
            property var note: tasks[index]

            Component.onDestruction: {
                tasks[index].contents = descriptionField.text
                tasks = tasks
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
                        tasks.splice(page.index, 1)
                        tasks = tasks
                    }
                }
            }
        }
    }
}

