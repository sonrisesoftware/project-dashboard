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
import Ubuntu.Layouts 0.1
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

    title: "Timer"
    iconSource: "clock"
    //unread: true

    property alias dates: doc.children
    property int totalTime: savedTime + currentTime
    property int currentTime: new Date() - startTime
    property int savedTime: doc.get("savedTime", 0)
    property int otherTime: List.iter(doc.children, function(docId) {
        if (docId === today.docId)
            return 0
        return doc.childrenData[docId]["time"]
    })
    property int allTime: otherTime + totalTime
    property var startTime: doc.get("startTime", undefined) === undefined ? undefined : new Date(doc.get("startTime", undefined))

    Component.onDestruction: today.set("time", totalTime)

    action: Action {
        text: startTime !== undefined ? i18n.tr("Stop") : i18n.tr("Start")
        onTriggered: {
            if (startTime) {
                doc.set("savedTime", savedTime + (new Date() - startTime))
                currentTime =  0
                doc.set("startTime", undefined)
            } else {
                doc.set("startTime", new Date().toJSON())
                currentTime = 0
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: startTime !== undefined
        onTriggered: {
            currentTime =  new Date() - startTime
        }
    }

    Document {
        id: today
        docId: new Date(new Date().toDateString()).toJSON()
        parent: doc

        Component.onCompleted: today.set("date", new Date().toJSON())
    }

    document: Document {
        id: doc
        docId: "timer"
        parent: project.document
    }

//    ListItem.SingleValue {
//        text: i18n.tr("Start time")
//        value: startTime !== undefined ? Qt.formatDateTime(startTime) :  "None"

//    }

//    ListItem.SingleValue {
//        text: i18n.tr("Saved time")
//        value: DateUtils.friendlyDuration(savedTime)

//    }

//    ListItem.SingleValue {
//        text: i18n.tr("Current time")
//        value: DateUtils.friendlyDuration(currentTime)

//    }

    ListItem.SingleValue {
        id: todayItem
        text: i18n.tr("Today")
        value: DateUtils.friendlyDuration(totalTime)
        onClicked: PopupUtils.open(editDialog, todayItem, {docId: today.docId})
    }

    viewAllMessage:  "View all days"
    summary: i18n.tr("Total Time")
    summaryValue: DateUtils.friendlyDuration(allTime)

    page: Component {
        PluginPage {
            title: "Timer"

            Layouts {
                id: layouts
                anchors.fill: parent

                layouts: [
                    ConditionalLayout {
                        name: "wideAspect"
                        when: wideAspect

                        Item {
                            anchors.fill: parent

                            Item {
                                anchors {
                                    left: parent.left
                                    right: parent.horizontalCenter
                                    top: parent.top
                                    bottom: parent.bottom
                                    margins: units.gu(2)
                                    rightMargin: units.gu(1)
                                }

                                ItemLayout {
                                    item: "timer"
                                    width: timerView.width
                                    height: timerView.height

                                    anchors.centerIn: parent
                                }
                            }

                            UbuntuShape {
                                color: Qt.rgba(0,0,0,0.2)
                                anchors {
                                    right: parent.right
                                    left: parent.horizontalCenter
                                    top: parent.top
                                    bottom: parent.bottom
                                    margins: units.gu(2)
                                    leftMargin: units.gu(1)
                                }
                                clip: true

                                ItemLayout {
                                    item: "list"

                                    anchors.fill: parent
                                }
                            }
                        }
                    },

                    ConditionalLayout {
                        name: "regularAspect"
                        when: !wideAspect

                        Item {
                            anchors.fill: parent

                            ItemLayout {
                                item: "list"

                                anchors.fill: parent
                            }
                        }
                    }
                ]

                // QML Element to draw the analogue clock face along with its hour, minute and second hands.
                ListView {
                    Layouts.item: "list"
                    model: dates
                    delegate: ListItem.SingleValue {
                        id: item
                        text: DateUtils.formattedDate(new Date(child.get("date", "")))
                        value: modelData === today.docId ? DateUtils.friendlyDuration(totalTime)
                                                         : DateUtils.friendlyDuration(child.get("time", 0))
                        onClicked: PopupUtils.open(editDialog, item, {docId: modelData})

                        Document {
                            id: child
                            docId: modelData
                            parent: doc
                        }
                    }
                }

                Column {
                    id: timerView
                    Layouts.item: "timer"
                    spacing: units.gu(1)

                    Label {
                        text: DateUtils.friendlyDuration(totalTime)
                        fontSize: "x-large"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: startTime !== undefined ? i18n.tr("Stop") : i18n.tr("Start")
                        onTriggered: {
                            if (startTime) {
                                doc.set("savedTime", savedTime + (new Date() - startTime))
                                currentTime =  0
                                doc.set("startTime", undefined)
                            } else {
                                doc.set("startTime", new Date().toJSON())
                                currentTime = 0
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: editDialog

        InputDialog {
            property alias docId: child.docId

            title: i18n.tr("Edit")
            text: i18n.tr("Edit the time logged for <b>%1</b>").arg(DateUtils.formattedDate(new Date(child.get("date"))))
            value: modelData === today.docId ? DateUtils.friendlyDuration(totalTime)
                                             : DateUtils.friendlyDuration(child.get("time", 0))

            property bool running

            Component.onCompleted: {
                if (docId == today.docId && startTime) {
                    doc.set("savedTime", savedTime + (new Date() - startTime))
                    currentTime =  0
                    doc.set("startTime", undefined)

                    running = true
                }
            }

            onAccepted: {
                if (docId == today.docId) {
                    doc.set("savedTime", DateUtils.parseDuration(value))

                    if (running) {
                        doc.set("startTime", new Date().toJSON())
                        currentTime = 0
                    }
                } else {
                    child.set("time", DateUtils.parseDuration(value))
                }
            }

            onRejected: {
                if (running) {
                    doc.set("startTime", new Date().toJSON())
                    currentTime = 0
                }
            }

            Document {
                id: child
                parent: doc
            }
        }
    }
}
