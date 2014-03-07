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

    title: "Tasks"
    iconSource: "list"
    //unread: true

    property alias tasks: doc.children
    property var openTasks: List.filter(tasks, function(docId) {
        return !doc.childrenData[docId].hasOwnProperty("done") || !doc.childrenData[docId]["done"]
    })
    unread: tasks.length > 0

    document: Document {
        id: doc
        docId: "tasks"
        parent: project.document
    }

    property int nextDocId: doc.get("nextDocId", 0)

    function addTask(title) {
        var docId = String(nextDocId)
        doc.set("nextDocId", nextDocId + 1)
        doc.newDoc(docId, {"title": title, "dueDate": ""})
        print(JSON.stringify(doc.save()))
        return docId
    }

    action: Action {
        text: i18n.tr("Add")
        onTriggered: PopupUtils.open(addPopover, value)
    }

    ListItem.Header {
        text: "Upcoming Tasks"
        visible: upcomingTasks.height > 0
    }

    Column {
        id: upcomingTasks
        width: parent.width

        Repeater {
            id: repeater
            model: tasks
            delegate: ToDoListItem {
                docId: modelData
                show: !task.get("done", false) && task.get("dueDate", "") !== "" && isDueThisWeek(new Date(task.get("dueDate", "")))
                tasks: doc

                Document {
                    id: task
                    docId: modelData
                    parent: doc
                }
            }
        }
    }

    ListItem.Header {
        text: "Recent Tasks"
        visible: upcomingTasks.height === 0 && openTasks.length === 0
    }

    Repeater {
        model: Math.min(4, openTasks.length)
        delegate: ToDoListItem {
            docId: openTasks[openTasks.length - index - 1]
            show: true
            tasks: doc
        }
    }

    ListItem.Standard {
        enabled: false
        visible: openTasks.length === 0
        text: "No tasks"
    }

    viewAllMessage:  "View all tasks"
    summary: openTasks.length > 0 ? i18n.tr("<b>%1</b> tasks").arg(openTasks.length) : i18n.tr("No tasks")

    Component {
        id: addPopover

        Popover {
            id: popover
            contentHeight: textField.height + units.gu(2)

            Component.onCompleted: textField.forceActiveFocus()

            Item {
                height: textField.height + units.gu(2)
                width: parent.width
                Button {
                    id: button
                    text: i18n.tr("Done")
                    onTriggered: {
                        PopupUtils.close(popover)
                        addTask(textField.text)
                    }

                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        margins: units.gu(1)
                    }
                }

                TextField {
                    id: textField
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: button.left
                        margins: units.gu(1)
                    }
                    onAccepted: button.trigger()
                }
            }
        }
    }

    page: Component {
        id: todoPage

        PluginPage {
            title: i18n.tr("Tasks")

            ListView {
                id: repeater
                anchors.fill: parent
                model: tasks
                delegate: ToDoListItem {
                    docId: modelData
                    tasks: doc

                    Document {
                        id: task
                        docId: modelData
                        parent: doc
                    }
                }
            }
        }
    }

    function isDueThisWeek(dueDate) {
        var date = new Date()
        date.setDate(date.getDate() + 7)

        return DateUtils.dateIsBeforeOrSame(dueDate, date)
    }
}
