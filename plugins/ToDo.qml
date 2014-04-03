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
import Ubuntu.Components.Pickers 0.1 as Picker
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

    function newTask(text, date) {
        tasks.push({"text": text, "done": false, "date": date ? date.toJSON(): undefined})
        tasks = tasks
        notification.show(i18n.tr("Task added"))
    }

    items: PluginItem {
        title: i18n.tr("Tasks")
        icon: "check-square-o"
        value: tasks.length > 0 ? tasks.length : ""

        action: Action {
            text: i18n.tr("Add Task")
            description: i18n.tr("Add a new task to your to do list")
            iconSource: getIcon("add")
            onTriggered: PopupUtils.open(addLinkDialog)
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
                delegate: ToDoListItem {
                    property var modelData: tasks[tasks.length - index - 1]
                    id: item
                    done: modelData.done
                    text: modelData.text
                    subText: modelData.date ? i18n.tr("Due %1").arg(DateUtils.formattedDate(new Date(modelData.date))) : ""

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
                onTriggered: PopupUtils.open(addLinkDialog)
            }

            ListView {
                id: listView
                anchors.fill: parent
                model: tasks
                delegate: ToDoListItem {
                    done: modelData.done
                    text: modelData.text
                    subText: modelData.date ? i18n.tr("Due %1").arg(DateUtils.formattedDate(new Date(modelData.date))) : ""

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

    Component {
        id: addLinkDialog
        Dialog {
            id: dialog

            title: i18n.tr("Add Task")
            text: i18n.tr("Enter the title and opionally the due date of your task:")

            property Resources plugin

            Component.onCompleted: titleField.parent.parent.height = Qt.binding(function() { return titleField.parent.height + dialog.__foreground.margins })

            TextField {
                id: titleField

                placeholderText: i18n.tr("Title")

                onAccepted: textField.forceActiveFocus()
                Keys.onTabPressed: textField.forceActiveFocus()
                style: DialogTextFieldStyle {}
            }

            Item {
                width: parent.width
                height: childrenRect.height

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr("Has due date:")
                }

                Switch {
                    id: dueDateSwitch
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                }
            }

            Item {
                width: parent.width
                height: dueDateSwitch.checked ? datePicker.height : 0
                opacity: dueDateSwitch.checked ? 1 : 0
                clip: true

                Behavior on height {
                    UbuntuNumberAnimation {}
                }

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }

                Picker.DatePicker {
                    id: datePicker
                    width: parent.width
                    date: new Date()
                    style: SuruDatePickerStyle {}
                    anchors.bottom: parent.bottom
                }
            }

            Item {
                width: parent.width
                height: childrenRect.height

                Button {
                    objectName: "cancelButton"
                    text: i18n.tr("Cancel")
                    anchors {
                        left: parent.left
                        right: parent.horizontalCenter
                        rightMargin: units.gu(1)
                    }

                    color: "gray"

                    onClicked: {
                        PopupUtils.close(dialog)
                    }
                }

                Button {
                    id: okButton
                    objectName: "okButton"

                    text: i18n.tr("Ok")
                    enabled: titleField.text !== ""
                    anchors {
                        left: parent.horizontalCenter
                        right: parent.right
                        leftMargin: units.gu(1)
                    }

                    onClicked: {
                        PopupUtils.close(dialog)
                        newTask(titleField.text, dueDateSwitch.checked ? datePicker.date : undefined)
                    }
                }
            }
        }
    }
}

