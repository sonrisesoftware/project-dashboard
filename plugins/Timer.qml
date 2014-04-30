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

import "../backend"
import "../components"
import "../qml-extras/listutils.js" as List
import "../qml-extras/dateutils.js" as DateUtils

import "../qml-air"
import "../qml-air/ListItems" as ListItem

Plugin {
    id: plugin

    name: "timer"

    onSave: {
        dates[today].time = totalTime
        doc.set("dates", dates)
    }

    function setup() {
        dates = doc.get("dates", {})
        if (!dates.hasOwnProperty(today)) {
            dates[today] = {
                "date": today,
                "time": 0
            }
        }
    }

    onLoaded: {
        dates = doc.get("dates", {})
        for (var key in dates) {
            if (dates[key].time === 0)
                delete dates[key]
        }

        if (!dates.hasOwnProperty(today)) {
            dates[today] = {
                "date": today,
                "time": 0
            }
            doc.set("savedTime", 0)
            doc.set("startTime", undefined)
        }
    }

    property string today: DateUtils.today.toJSON()

    property var dates: doc.get("dates", {})
    property int totalTime: savedTime + currentTime
    property int currentTime: 0
    property int savedTime: doc.get("savedTime", 0)
    property int otherTime: {
        var time = 0
        for (var key in dates) {
            if (key !== today)
                time += dates[key].time
        }
        return time
    }

    property int allTime: otherTime + totalTime
    property var startTime: doc.get("startTime", undefined) === undefined ? undefined : new Date(doc.get("startTime", undefined))

    function startOrStop() {
        if (startTime) {
            doc.set("savedTime", savedTime + (new Date() - startTime))
            currentTime =  0
            doc.set("startTime", undefined)
        } else {
            doc.set("startTime", new Date().toJSON())
            currentTime = 0
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        running: startTime !== undefined
        onTriggered: {
            currentTime =  new Date() - startTime
        }
    }

    items: PluginItem {
        icon: "clock"
        title: i18n.tr("Time Tracker")
        shortTitle: i18n.tr("Timer")
        value: DateUtils.friendlyDuration(allTime)

        action: Action {
            name: timer.running ? i18n.tr("Pause Timer") : i18n.tr("Start Timer")
            onTriggered: startOrStop()
        }

        pulseItem: PulseItem {
            id: pulseItem
            show: totalTime > 0 || timer.running
            title: i18n.tr("Time Tracked Today")
            viewAll: i18n.tr("View all days")

            ListItem.Standard {
                text: i18n.tr("No time tracked today")
                visible: !pulseItem.show
                enabled: false
                height: visible ? implicitHeight : 0
                implicitHeight: units.gu(5)
            }

            ListItem.SingleValue {
                id: todayItem
                text: i18n.tr("Today")
                value: DateUtils.friendlyDuration(totalTime)
                onClicked: PopupUtils.open(editDialog, todayItem, {date: today})
                visible: pulseItem.show
                height: visible ? implicitHeight : 0
                implicitHeight: units.gu(5)
            }
        }

        page: PluginPage {
            id: page
            title: "Timer"

            Item {
                id: timerPage

                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.horizontalCenter
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                Column {
                    id: timerView
                    anchors.centerIn: parent
                    spacing: units.gu(1)

                    Label {
                        text: DateUtils.friendlyDuration(totalTime)
                        font.pixelSize: units.gu(3.5)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: units.gu(1)

                        Button {
                            text: startTime !== undefined ? i18n.tr("Stop") : i18n.tr("Start")
                            style: startTime === undefined ? "success" : "danger"
                            onClicked: startOrStop()
                        }

                        Button {
                            text: i18n.tr("Edit")
                            onClicked: PopupUtils.open(editDialog, timerView, {date: today})
                        }
                    }
                }
            }

            Item {
                id: historyPage
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.horizontalCenter
                }

                BackgroundView {
                    id: list
                    anchors.fill: parent
                    anchors.margins: units.gu(2)
                    radius: units.gu(0.5)
                    opacity: wideAspect ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    ListView {
                        anchors.fill: parent
                        anchors.bottomMargin: footer.height
                        model: List.objectKeys(dates).sort(function(a,b) {
                            return new Date(b) - new Date(a)
                        })
                        clip: true
                        delegate: ListItem.SingleValue {
                            id: item
                            height: units.gu(5)
                            text: DateUtils.formattedDate(new Date(modelData))
                            value: modelData === today ? DateUtils.friendlyDuration(totalTime)
                                                             : DateUtils.friendlyDuration(dates[modelData].time)
                            onClicked: PopupUtils.open(editDialog, plugin, {date: modelData})
                        }
                    }

                    Item {
                        anchors.bottom: parent.bottom
                        height: footer.height
                        width: parent.width
                        clip: true
                        BackgroundView {
                            anchors.bottom: parent.bottom
                            height: list.height
                            width: parent.width
                            radius: units.gu(0.5)

                            color: "#eee"
                            border.color: Qt.rgba(0,0,0,0.1)
                        }
                    }

                    Column {
                        id: footer

                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }

                        ListItem.ThinDivider {}
                        ListItem.SingleValue {
                            text: i18n.tr("Total Time")
                            value: DateUtils.friendlyDuration(allTime)
                            showDivider: false
                            highlightable: false
                            height: units.gu(4.5)
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: editDialog

        property string date

        title: i18n.tr("Edit Time")
        text: i18n.tr("Edit the time logged for <b>%1</b>").arg(DateUtils.formattedDate(new Date(dates[date].date)))

//        DatePicker {
//            id: datePicker
//            width: parent.width
//            date: root.date === today ? DateUtils.toUTC(new Date(totalTime)) : DateUtils.toUTC(new Date(dates[root.date].time))
//            mode: "Hours|Minutes|Seconds"
//            style: SuruDatePickerStyle {}
//        }

        property bool running

        Component.onCompleted: {
            if (date == today ) {
                //datePicker.date = new Date(totalTime).getUTCDate()
                if (startTime) {
                    doc.set("savedTime", savedTime + (new Date() - startTime))
                    currentTime =  0
                    doc.set("startTime", undefined)

                    running = true
                }
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
                    PopupUtils.close(root)
                    if (running) {
                        doc.set("startTime", new Date().toJSON())
                        currentTime = 0
                    }
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

                onClicked: {
                    PopupUtils.close(root)
                    print(datePicker.date)
                    if (date == today) {
                        doc.set("savedTime", DateUtils.timeFromDate(datePicker.date))

                        if (running) {
                            doc.set("startTime", new Date().toJSON())
                            currentTime = 0
                        }
                    } else {
                        dates[date].time = DateUtils.timeFromDate(datePicker.date)
                        dates = dates
                    }
                }
            }
        }
    }
}
