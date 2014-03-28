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
import "../backend/services"
import "../ubuntu-ui-extras"
import "../ubuntu-ui-extras/dateutils.js" as DateUtils

Plugin {
    id: plugin

    property var events: doc.get("events", [])

    onSave: {
        doc.set("events", events)
    }

    items: PluginItem {
        title: "Events"
        icon: "calendar"

        action: Action {
            id: addAction
            text: i18n.tr("Add Event")
            description: i18n.tr("Add an event to your project's calendar")
            onTriggered: PopupUtils.open(Qt.resolvedUrl("resources/AddLinkDialog.qml"), value, {plugin: plugin})
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

            ListItem.Subtitled {
                text: visible ? events[0].title : ""
                subText: visible ? Qt.formatDate(events[0].date) : ""
                visible: events.length > 0
                height: visible ? implicitHeight : 0
            }
        }

        page: Component {
            PluginPage {
                title: i18n.tr("Events")
                actions: Action {
                    id: addAction
                    iconSource: getIcon("add")
                    text: i18n.tr("Add")
                    description: i18n.tr("Add an event to your project's calendar")
                    onTriggered: PopupUtils.open(Qt.resolvedUrl("resources/AddLinkDialog.qml"), value, {plugin: plugin})
                }

                flickable: listView.count === 0 ? null : listView
                ListView {
                    id: listView
                    anchors.fill: parent

                    model: documents.length
                    delegate: ListItem.Subtitled {
                        id: item
                        property var modelData: documents[documents.length - index - 1]
                        text: modelData.title
                        subText: modelData.text

                        onClicked: pageStack.push(Qt.resolvedUrl("resources/WebPage.qml"), {resource: modelData})
                        onPressAndHold: PopupUtils.open(actionsPopover, item, {index: documents.length - index - 1})
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
                    text: i18n.tr("No saved resources")
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
                                    documents.splice(actionsPopoverItem.index, 1)
                                    documents = documents
                                }
                            }

                            Action {
                                text: i18n.tr("Edit")
                                onTriggered: {
                                    if (documents[actionsPopoverItem.index].type === "link")
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

                        title: i18n.tr("Edit Link")
                        text: i18n.tr("Edit the title or link:")

                        TextField {
                            id: titleField

                            placeholderText: i18n.tr("Title")
                            text: documents[index].title

                            onAccepted: textField.forceActiveFocus()
                            Keys.onTabPressed: descriptionField.forceActiveFocus()
                            color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText
                        }

                        TextField {
                            id: textField

                            placeholderText: i18n.tr("Link")
                            text: documents[index].text
                            color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                            onAccepted: okButton.clicked()
                            validator: RegExpValidator {
                                regExp: /.+/
                            }
                        }

                        Item {
                            width: parent.width
                            height: childrenRect.height
                            Button {
                                id: okButton
                                objectName: "okButton"
                                anchors {
                                    left: parent.left
                                    right: parent.horizontalCenter
                                    rightMargin: units.gu(1)
                                }

                                text: i18n.tr("Ok")
                                enabled: textField.acceptableInput

                                onClicked: {
                                    PopupUtils.close(root)
                                    documents[index] = {"title": titleField.text, "type": "link", "text": textField.text}
                                    documents = documents
                                }
                            }

                            Button {
                                objectName: "cancelButton"
                                text: i18n.tr("Cancel")
                                anchors {
                                    left: parent.horizontalCenter
                                    right: parent.right
                                    leftMargin: units.gu(1)
                                }

                                color: "gray"

                                onClicked: {
                                    PopupUtils.close(root)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
