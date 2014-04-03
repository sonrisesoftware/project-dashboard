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
import Ubuntu.Components.Pickers 0.1 as Picker
import "../backend"
import "../components"
import "../backend/services"
import "../ubuntu-ui-extras"
import "../ubuntu-ui-extras/dateutils.js" as DateUtils

Plugin {
    id: plugin

    property var events: []

    onSave: {
        doc.set("events", events)
    }

    onLoaded: {
        events = doc.get("events", [])
        events.sort(function(a,b) {
            return new Date(a.date) - new Date(b.date)
        })
        while (DateUtils.dateIsBefore(new Date(events[0].date), new Date())) {
            events.splice(0, 1)
        }

        events = events
    }

    function addEvent(title, date) {
        print("Adding", title, date)
        events.push({
                        "title": title,
                        "date": date.toJSON()
                    })
        events.sort(function(a,b) {
            return new Date(a.date) - new Date(b.date)
        })
        events = events
    }

    items: PluginItem {
        id: eventsItem
        title: "Events"
        icon: "calendar"
        value: events.length > 0 ? events.length : ""

        action: Action {
            id: addAction
            text: i18n.tr("Add Event")
            description: i18n.tr("Add an event to your project's calendar")
            onTriggered: PopupUtils.open(addLinkDialog, plugin)
        }

        pulseItem: PulseItem {
            title: i18n.tr("Next Event")
            viewAll: i18n.tr("View all events")
            show: events.length > 0

            ListItem.Standard {
                text: i18n.tr("No upcoming events")
                enabled: false
                visible: events.length === 0
                height: visible ? implicitHeight : 0
            }

            SubtitledListItem {
                text: visible ? events[0].title : ""
                subText: visible ? new Date(events[0].date).toDateString() : ""
                visible: events.length > 0
                height: visible ? implicitHeight : 0

                onClicked: pageStack.push(eventsItem.page)

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)

                    text: events.length === 0 ? "" : DateUtils.isToday(new Date(events[0].date)) ? i18n.tr("Today")
                                                                                                 : i18n.tr("%1 days").arg(DateUtils.daysUntilDate(new Date(events[0].date)))
                }
            }
        }

        page: PluginPage {
            title: i18n.tr("Events")
            actions: Action {
                iconSource: getIcon("add")
                text: i18n.tr("Add")
                description: i18n.tr("Add an event to your project's calendar")
                onTriggered: PopupUtils.open(addLinkDialog, plugin)
            }

            flickable: listView.count === 0 ? null : listView
            ListView {
                id: listView
                anchors.fill: parent

                model: events
                delegate: SubtitledListItem {
                    id: item
                    text: modelData.title
                    subText: new Date(modelData.date).toDateString()

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)

                        text: DateUtils.isToday(new Date(modelData.date)) ? i18n.tr("Today")
                                                                          : i18n.tr("%1 days").arg(DateUtils.daysUntilDate(new Date(modelData.date)))
                    }

                    removable: true
                    onItemRemoved: {
                        events.splice(index, 1)
                        events = events
                    }

                    backgroundIndicator: ListItemBackground {
                        state: item.swipingState
                        text: i18n.tr("Remove")
                        iconSource: getIcon("delete-white")
                    }

                    onClicked: PopupUtils.open(editLinkDialog, item, {index: index})
                }
            }

            Scrollbar {
                flickableItem: listView
            }

            Label {
                anchors.centerIn: parent
                visible: listView.count == 0
                opacity: 0.5
                fontSize: "large"
                text: i18n.tr("No events")
            }

            Component {
                id: actionsPopover

                ActionSelectionPopover {
                    id: actionsPopoverItem
                    property int index

                    actions: ActionList {
                        Action {
                            text: i18n.tr("Remove")
                            onTriggered: {
                                events.splice(actionsPopoverItem.index, 1)
                                events = events
                            }
                        }

                        Action {
                            text: i18n.tr("Edit")
                            onTriggered: {
                                PopupUtils.open(editLinkDialog, plugin, {index: actionsPopoverItem.index})
                            }
                        }
                    }
                }
            }

            Component {
                id: editLinkDialog

                Dialog {
                    id: root

                    property int index

                    title: i18n.tr("Edit Event")
                    text: i18n.tr("Edit the title or date:")

                    TextField {
                        id: titleField

                        placeholderText: i18n.tr("Title")
                        text: events[index].title

                        onAccepted: textField.forceActiveFocus()
                        Keys.onTabPressed: descriptionField.forceActiveFocus()
                        style: DialogTextFieldStyle {}
                    }

                    Picker.DatePicker {
                        id: datePicker
                        width: parent.width
                        date: new Date(events[index].date)
                        style: SuruDatePickerStyle {}
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
                                PopupUtils.close(root)
                            }
                        }

                        Button {
                            id: okButton
                            objectName: "okButton"
                            anchors {
                                left: parent.horizontalCenter
                                right: parent.right
                                leftMargin: units.gu(1)
                            }

                            text: i18n.tr("Ok")
                            enabled: titleField.text !== ""

                            onClicked: {
                                PopupUtils.close(root)
                                events[root.index] = {
                                    "title": titleField.text,
                                    "date": datePicker.date
                                }
                                events = events
                            }
                        }
                    }
                }
            }
        }

    }


    Component {
        id: addLinkDialog
        Dialog {
            id: dialog

            title: i18n.tr("Add Event")
            text: i18n.tr("Enter title and date of your event:")

            property Resources plugin

            TextField {
                id: titleField

                placeholderText: i18n.tr("Title")

                onAccepted: textField.forceActiveFocus()
                Keys.onTabPressed: textField.forceActiveFocus()
                style: DialogTextFieldStyle {}
            }

            Picker.DatePicker {
                id: datePicker
                width: parent.width
                date: new Date()
                style: SuruDatePickerStyle {}
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
                        PopupUtils.close(root)
                    }
                }

                Button {
                    id: okButton
                    objectName: "okButton"
                    anchors {
                        left: parent.horizontalCenter
                        right: parent.right
                        leftMargin: units.gu(1)
                    }

                    text: i18n.tr("Ok")
                    enabled: titleField.text !== ""

                    onClicked: {
                        PopupUtils.close(root)
                        addEvent(titleField.text, datePicker.date)
                    }
                }
            }
        }
    }
}
