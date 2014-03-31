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
        value: DateUtils.friendlyDuration(allTime)

        action: Action {
            text: timer.running ? i18n.tr("Pause Timer") : i18n.tr("Start Timer")
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
            }

            ListItem.SingleValue {
                id: todayItem
                text: i18n.tr("Today")
                value: DateUtils.friendlyDuration(totalTime)
                onClicked: PopupUtils.open(editDialog, todayItem, {date: today})
                visible: pulseItem.show
                height: visible ? implicitHeight : 0
            }
        }

        page: PluginPage {
            id: page
            title: "Timer"

            tabs: wideAspect ? [i18n.tr("Timer")] : [i18n.tr("Timer"), i18n.tr("History")]

            Item {
                id: timerPage
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    leftMargin: show ? 0 : -width

                    Behavior on leftMargin {
                        UbuntuNumberAnimation {}
                    }
                }

                width: parent.width
                property bool show: page.selectedTab === i18n.tr("Timer")

                opacity: show ? 1 : 0

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }

                Column {
                    id: timerView
                    anchors.centerIn: parent
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
                            color: startTime === undefined ? colors["green"] : colors["red"]
                            onTriggered: startOrStop()
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
                    rightMargin: show ? 0 : -width

                    Behavior on rightMargin {
                        UbuntuNumberAnimation {}
                    }
                }

                width: parent.width
                property bool show: !timerPage.show

                opacity: show ? 1 : 0

                Behavior on opacity {
                    UbuntuNumberAnimation {}
                }

//                ItemLayout {
//                    anchors.fill: parent
//                    anchors.topMargin: units.gu(1)
//                    item: "list"
//                }

                Item {
                    id: list
                    anchors.fill: parent
                    anchors.margins: wideAspect ? units.gu(2) : 0

                    Behavior on anchors.margins {
                        UbuntuNumberAnimation {}
                    }

                    UbuntuShape {
                        anchors.fill: parent
                        color: Qt.rgba(0,0,0,0.2)
                        opacity: wideAspect ? 1 : 0

                        Behavior on opacity {
                            UbuntuNumberAnimation {}
                        }
                    }

                    ListView {
                        anchors.fill: parent
                        model: List.objectKeys(dates)
                        delegate: ListItem.SingleValue {
                            id: item
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
                        visible: wideAspect
                        clip: true
                        UbuntuShape {
                            anchors.bottom: parent.bottom
                            height: list.height
                            width: parent.width
                            color: Qt.rgba(0,0,0,0.2)
                        }
                    }

                    Rectangle {
                        anchors.fill: footer
                        color: Qt.rgba(0,0,0,0.2)
                        visible: !wideAspect
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
                            height: units.gu(4.5)
                        }
                    }
                }
            }

            states: [
                State {
                    name: "wide"
                    when: wideAspect
                    PropertyChanges {
                        restoreEntryValues: true
                        target: timerPage
                        width: parent.width/2
                        show: true
                    }

                    PropertyChanges {
                        restoreEntryValues: true
                        target: historyPage
                        width: parent.width/2
                        show: true
                    }
                }

            ]

            transitions: [
                Transition {
                    from: "*"
                    to: "wide"

                    UbuntuNumberAnimation {
                        target: timerPage
                        property: "width"
                    }

                    UbuntuNumberAnimation {
                        target: historyPage
                        property: "width"
                    }
                },

                Transition {
                    from: "wide"
                    to: "*"

                    NumberAnimation { target: timerPage; property: "anchors.leftMargin"; duration: 0;  }
                    NumberAnimation { target: historyPage; property: "anchors.rightMargin"; duration: 0;  }
                }

            ]

//            Layouts {
//                id: layouts
//                anchors.fill: parent

//                layouts: [
//                    ConditionalLayout {
//                        name: "wideAspect"
//                        when: wideAspect

//                        Item {
//                            anchors.fill: parent

//                            Item {
//                                anchors {
//                                    left: parent.left
//                                    right: parent.horizontalCenter
//                                    top: parent.top
//                                    bottom: parent.bottom
//                                    margins: units.gu(2)
//                                    rightMargin: units.gu(1)
//                                }

//                                ItemLayout {
//                                    item: "timer"
//                                    width: timerView.width
//                                    height: timerView.height

//                                    anchors.centerIn: parent
//                                }
//                            }

//                            UbuntuShape {
//                                id: shape
//                                color: Qt.rgba(0,0,0,0.2)
//                                anchors {
//                                    right: parent.right
//                                    left: parent.horizontalCenter
//                                    top: parent.top
//                                    bottom: parent.bottom
//                                    margins: units.gu(2)
//                                    leftMargin: units.gu(1)
//                                }
//                                clip: true

//                                ItemLayout {
//                                    item: "list"

//                                    anchors.fill: parent
//                                }

//                                Item {
//                                    anchors.bottom: parent.bottom
//                                    height: footer.height
//                                    width: parent.width
//                                    clip: true
//                                    UbuntuShape {
//                                        anchors.bottom: parent.bottom
//                                        height: shape.height
//                                        width: parent.width
//                                        color: Qt.rgba(0,0,0,0.2)
//                                        ItemLayout {
//                                            item: "footer"

//                                            anchors {
//                                                left: parent.left
//                                                right: parent.right
//                                                bottom: parent.bottom
//                                            }

//                                            height: footer.height
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    },

//                    ConditionalLayout {
//                        name: "regularAspect"
//                        when: !wideAspect


//                    }
//                ]

//            }
        }
    }

    Component {
        id: editDialog

        InputDialog {
            property string date

            title: i18n.tr("Edit Time")
            text: i18n.tr("Edit the time logged for <b>%1</b>").arg(DateUtils.formattedDate(new Date(dates[date].date)))
            value: date === today ? DateUtils.friendlyDuration(totalTime)
                                             : DateUtils.friendlyDuration(dates[date].time)

            property bool running

            Component.onCompleted: {
                if (date == today ) {
                    value = DateUtils.friendlyDuration(totalTime)
                    if (startTime) {
                        doc.set("savedTime", savedTime + (new Date() - startTime))
                        currentTime =  0
                        doc.set("startTime", undefined)

                        running = true
                    }
                }
            }

            onAccepted: {
                if (date == today) {
                    doc.set("savedTime", DateUtils.parseDuration(value))

                    if (running) {
                        doc.set("startTime", new Date().toJSON())
                        currentTime = 0
                    }
                } else {
                    dates[date].time = DateUtils.parseDuration(value)
                    dates = dates
                }
            }

            onRejected: {
                if (running) {
                    doc.set("startTime", new Date().toJSON())
                    currentTime = 0
                }
            }
        }
    }
}
