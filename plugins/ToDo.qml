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
    id: root

    title: "Tasks"
    iconSource: "list"
    //unread: true

    onTriggered: pageStack.push(todoPage)

    property alias tasks: doc.children
    unread: tasks.length > 0

    document: Document {
        id: doc
        docId: backend.getPlugin("tasks").docId
        parent: root.project.document
    }

    ListItem.Header {
        text: "Upcoming Tasks"
        visible: tasks.length > 0
    }

    Repeater {
        id: repeater
        model: tasks
        delegate: ToDoListItem {
            docId: modelData
            show: task.get("dueDate", "") !== "" && isDueThisWeek(new Date(task.get("dueDate", "")))
            tasks: doc

            Document {
                id: task
                docId: modelData
                parent: doc
            }
        }
    }

    ListItem.Standard {
        enabled: false
        visible: tasks.length === 0
        text: "No upcoming tasks"
    }

    viewAllMessage:  "View all tasks"
    summary: tasks.length > 0 ? i18n.tr("<b>%1</b> tasks").arg(tasks.length) : i18n.tr("No tasks")

    Component {
        id: todoPage

        Page {
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

            tools: ToolbarItems {
                opened: wideAspect
                locked: wideAspect

                onLockedChanged: opened = locked
            }
        }
    }

    function isDueThisWeek(dueDate) {
        var date = new Date()
        date.setDate(date.getDate() + 7)

        return DateUtils.dateIsBeforeOrSame(dueDate, date)
    }
}
