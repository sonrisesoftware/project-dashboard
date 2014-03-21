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

    name: "timer"

    property var dates: doc.get("dates", [])
    property int totalTime: savedTime + currentTime
    property int currentTime: 0//new Date() - startTime
    property int savedTime: today.get("savedTime", 0)
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
                today.set("savedTime", savedTime + (new Date() - startTime))
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
        docId: {
            var today = DateUtils.today
            return today.toJSON()
        }

        parent: doc
    }

    document: Document {
        id: doc
        docId: "timer"
        parent: project.document
    }

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
                                id: shape
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

                                Item {
                                    anchors.bottom: parent.bottom
                                    height: footer.height
                                    width: parent.width
                                    clip: true
                                    UbuntuShape {
                                        anchors.bottom: parent.bottom
                                        height: shape.height
                                        width: parent.width
                                        color: Qt.rgba(0,0,0,0.2)
                                        ItemLayout {
                                            item: "footer"

                                            anchors {
                                                left: parent.left
                                                right: parent.right
                                                bottom: parent.bottom
                                            }

                                            height: footer.height
                                        }
                                    }
                                }
                            }
                        }
                    },

                    ConditionalLayout {
                        name: "regularAspect"
                        when: !wideAspect

                        Item {
                            id: regLayout
                            anchors.fill: parent

                            property bool timerSelected: true

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: -units.gu(1.2)
                                height: header.height - header.__styleInstance.contentHeight + units.gu(1)
                                parent: header
                                width: parent.width
                                color: "#3e3e3e" //FIXME: This color is hard-coded based on the current app background color

                                Image {
                                    id: separatorBottom
                                    anchors {
                                        bottom: parent.bottom
                                        left: parent.left
                                        right: parent.right
                                    }
                                    source: getIcon("PageHeaderBaseDividerBottom.png")
                                }

                                Row {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: units.gu(-0.1)
                                    spacing: units.gu(1)

                                    Label {
                                        text: "Timer"
                                        color: regLayout.timerSelected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: regLayout.timerSelected = true
                                        }
                                    }

                                    Label {
                                        text: "|"
                                    }

                                    Label {
                                        text: "History"
                                        color: !regLayout.timerSelected ? UbuntuColors.orange : Theme.palette.selected.backgroundText
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: regLayout.timerSelected = false
                                        }
                                    }
                                }
                            }

                            ItemLayout {
                                anchors.fill: parent
                                anchors.topMargin: units.gu(1)
                                item: "list"
                                visible: !regLayout.timerSelected
                            }

                            Item {
                                anchors.fill: parent
                                anchors.topMargin: units.gu(1) - header.height
                                ItemLayout {
                                    anchors.centerIn: parent
                                    item: "timer"
                                    width: timerView.width
                                    height: timerView.height
                                }
                                visible: regLayout.timerSelected
                            }

                            Rectangle {
                                anchors.fill: column
                                color: Qt.rgba(0,0,0,0.2)
                                visible: !regLayout.timerSelected
                            }

                            ItemLayout {
                                id: column
                                item: "footer"
                                visible: !regLayout.timerSelected

                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }

                                height: footer.height
                            }
                        }
                    }
                ]

                ListView {
                    Layouts.item: "list"
                    model: dates
                    delegate: ListItem.SingleValue {
                        id: item
                        text: DateUtils.formattedDate(new Date(child.docId))
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

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: units.gu(1)

                        Button {
                            text: startTime !== undefined ? i18n.tr("Stop") : i18n.tr("Start")
                            onTriggered: {
                                if (startTime) {
                                    today.set("savedTime", savedTime + (new Date() - startTime))
                                    currentTime =  0
                                    doc.set("startTime", undefined)
                                } else {
                                    doc.set("startTime", new Date().toJSON())
                                    currentTime = 0
                                }
                            }
                        }

//                        Button {
//                            text: i18n.tr("Edit")
//                            onTriggered: PopupUtils.open(editDialog, todayItem, {docId: today.docId})
//                        }
                    }
                }

                Column {
                    id: footer
                    Layouts.item: "footer"

                    width: units.gu(20)

                    ListItem.ThinDivider {}
                    ListItem.SingleValue {
                        text: i18n.tr("Total Time")
                        value: DateUtils.friendlyDuration(allTime)
                        showDivider: false
                        height: units.gu(4.5)
                    }
                }
            }
        }
    }

    Component {
        id: editDialog

        InputDialog {
            property alias docId: child.docId

            title: i18n.tr("Edit Time")
            text: i18n.tr("Edit the time logged for <b>%1</b>").arg(DateUtils.formattedDate(new Date(child.docId)))
            value: modelData === today.docId ? DateUtils.friendlyDuration(totalTime)
                                             : DateUtils.friendlyDuration(child.get("time", 0))

            property bool running

            Component.onCompleted: {
                if (docId == today.docId ) {
                    value = DateUtils.friendlyDuration(totalTime)
                    if (startTime) {
                        today.set("savedTime", savedTime + (new Date() - startTime))
                        currentTime =  0
                        doc.set("startTime", undefined)

                        running = true
                    }
                }
            }

            onAccepted: {
                if (docId == today.docId) {
                    today.set("savedTime", DateUtils.parseDuration(value))

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
