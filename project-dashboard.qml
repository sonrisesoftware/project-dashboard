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
import "components"
import "ui"
import "backend"
import "backend/services"
import "parse_backend"

import "qml-air"
import "qml-air/ListItems" as ListItem
import "qml-extras"
import "qml-extras/listutils.js" as List
import "qml-extras/httplib.js" as Http

import "backend/diff_match_patch.js" as DiffMatchPatch

/*!
    \brief MainView with a Label and Button elements.
*/

PageApplication {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    title: "Project Dashboard"

    width: units.gu(100)
    height: units.gu(75)

    property var colors: {
        "green": "#5cb85c",//"#59B159",//"#859a01",
        "red": "#db3131",//"#d9534f",//"#db3131",
        "yellow": "#f0ad4e",//"#b68b01",
        "blue": "#5bc0de",
        //"default": Theme.palette.normal.baseText,
    }

    property bool wideAspect: width > units.gu(80)
    property bool extraWideAspect: width > units.gu(150)

    initialPage: rootPage

    ProjectsPage {
        id: rootPage

        leftWidgets: Button {
            style: "primary"
            text: "New Project"
            onClicked: newSheet.open()
        }

        rightWidgets: [
            Button {
                iconName: syncError || noConnection ? "exclamation-triangle" : "spinner-rotate"
                iconColor: noConnection ? theme.warning : syncError ? theme.danger : textColor
                text: noConnection ? "No connection" : syncError ? "Sync error" : "Syncing..."
                opacity: busy || syncError || noConnection ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                onClicked: if (!noConnection) syncPopover.open()
            },

            Button {
                iconName: inboxPopover.count > 0 ? "bell" : "bell-o"
                iconColor: inboxPopover.count > 0 ? theme.danger : textColor
                onClicked: inboxPopover.open(caller)
            },

//            Button {
//                iconName: "user"
//                onClicked: userPopover.open(caller)
//            },

            Button {
                iconName: "cog"
                onClicked: configMenu.open(caller)
            }
        ]
    }

    InputDialog {
        id: newSheet

        title: i18n.tr("Create New Project")
        text: i18n.tr("Please enter a name for your new project:")
        placeholderText: i18n.tr("Name")
        onAccepted: {
            var project = backend.newProject(value)
            pageStack.push(Qt.resolvedUrl("ui/ProjectPage.qml"), {project: project})
            notification.show(i18n.tr("Project created"))
        }
    }

    ActionPopover {
        id: configMenu
        actions: [
            Action {
                name: "About"
                onTriggered: aboutSheet.open()
            },

            Action {
                name: "Settings"
                onTriggered: settingsPage.open()
            }
        ]
    }

    UserPopover {
        id: userPopover
    }

    SettingsPage {
        id: settingsPage
    }

    Sheet {
        id: accountSheet

        title: "Account Details"
        confirmButton: false
    }

    AboutSheet {
        id: aboutSheet

        appName: i18n.tr("Project Dashboard")
        icon: Qt.resolvedUrl("project-dashboard-shadowed.png")
        version: "@APP_VERSION@"
        credits: {
            var credits = {}
            credits[i18n.tr("Icon")] = "Sam Hewitt"
            credits[i18n.tr("Debian Packaging")] = "Nekhelesh Ramananthan"
            return credits
        }

        website: "http://www.sonrisesoftware.com/apps/project-dashboard"
        reportABug: "https://github.com/iBeliever/project-dashboard/issues"

        copyright: i18n.tr("Copyright (c) 2014 Michael Spencer. All Rights Reserved.")
        author: "Sonrise Software"
        contactEmail: "sonrisesoftware@gmail.com"
    }

    property bool syncError: List.iter(backend.projects, function(project) {
        return project.syncQueue.hasError
    }) > 0
    property bool busy: List.iter(backend.projects, function(project) {
        return project.syncQueue.count
    }) > 0
    property bool noConnection: !connection.connected

    InternetConnection {
        id: connection
    }

    Popover {
        id: inboxPopover

        property int count: List.concat(backend.projects, "inbox").length

        contentHeight: count > 0 ? inboxList.height + clearButton.height + units.gu(2) : noMessagesView.height

        Item {
            id: noMessagesView
            width: parent.width
            height: inboxPopover.count === 0 ? units.gu(6) : 0
            visible: inboxPopover.count === 0

            Label {
               anchors.centerIn: parent
               text: "No unread messages"
               opacity: 0.5
            }
        }

        Button {
            id: clearButton
            visible: inboxPopover.count > 0
            onClicked: backend.clearInbox()
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom

                margins: units.gu(1)
            }

            text: "Mark all as read"
        }

        ListView {
            id: inboxList
            width: parent.width
            height: Math.min(contentHeight, units.gu(5 * 10))

            model: backend.projects
            clip: true
            delegate: Column {
                width: parent.width
                property Project project: modelData

                ListItem.Header {
                    text: project.name
                    opacity: repeater.count > 0 ? 1 : 0
                    visible: opacity > 0

                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(2)
                        }
                        text: repeater.count
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 250; }
                    }
                }

                Repeater {
                    id: repeater
                    model: project.inbox
                    delegate: ListItem.BaseListItem {
                        id: listItem
                        onClicked: project.displayMessage(modelData)

                        height: units.gu(5)

                        removable: true
                        onItemRemoved: project.removeMessage(index)
                        backgroundIndicator: ListItemBackground {
                            ready: swipingReady
                            iconName: "check"
                            actionBackground: theme.success
                            state: listItem.swipingState
                        }

                        AwesomeIcon {
                            id: icon
                            name: modelData.icon
                            size: units.gu(3.5)
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: units.gu(1.5)
                            }
                        }

                        Column {
                            id: labels

                            spacing: units.gu(0.1)

                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: icon.right
                                leftMargin: units.gu(1.5)
                                rightMargin: units.gu(2)
                                right: parent.right
                            }

                            Item {
                                width: parent.width
                                height: childrenRect.height
                                Label {
                                    id: titleLabel

                                    width: parent.width - dateLabel.width - units.gu(1)
                                    elide: Text.ElideRight
                                    text: modelData.title
                                }

                                Label {
                                    id: dateLabel
                                    font.italic: true
                                    text: friendlyTime(new Date(modelData.date))
                                    anchors.right: parent.right
                                    color: theme.secondaryColor
                                    fontSize: "small"
                                }
                            }

                            Label {
                                id: subLabel
                                width: parent.width

                                height: visible ? implicitHeight: 0
                                color: theme.secondaryColor
                                maximumLineCount: 1
                                font.weight: Font.Light
                                fontSize: "small"
                                text: modelData.message
                                visible: text !== ""
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }

        ListItem.ThinDivider {
            anchors.bottom: inboxList.bottom
        }

        ScrollBar {
            flickableItem: inboxList
        }
    }

    Popover {
        id: syncPopover
        contentHeight: column.height

        onContentHeightChanged: {
            if (contentHeight == 0)
                syncPopover.close()
        }

        Column {
            id: column
            width: parent.width

            Repeater {
                model: backend.projects
                delegate: Column {
                    id: syncColumn
                    width: parent.width

                    property Project project: modelData

                    visible: List.objectKeys(modelData.syncQueue.groups).length > 0

                    ListItem.Header {
                        text: modelData.name
                        height: List.objectKeys(modelData.syncQueue.groups).length > 0 ? units.gu(4) : 0
                    }

                    Repeater {
                        model: List.objectKeys(modelData.syncQueue.groups)
                        delegate: SubtitledListItem {
                            id: item
                            property var group: syncColumn.project.syncQueue.groups[modelData]
                            text: group.title
                            subText: group.errors.length > 0 ? i18n.tr("Error: %1").arg(group.errors[0].status)
                                                             : ""

                            onClicked: {
                                print("Clicked")
                                error(i18n.tr("%1 Failed").arg(group.title), i18n.tr("Call: %1\n\n%2").arg(group.errors[0].call).arg(group.errors[0].response))
                            }

                            ProgressBar {
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: units.gu(2)
                                }
                                minimumValue: 0
                                maximumValue: group.total
                                value: item.group.total - item.group.count
                                visible: item.group.count > 0
                                width: units.gu(10)
                                height: units.gu(2.5)
                            }

                            AwesomeIcon {
                                name: "exclamation-triangle"
                                color: colors["yellow"]
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: (parent.height - height)/2
                                }
                                size: units.gu(2.6)
                                opacity: item.group.errors.length > 0 ? 1 : 0

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 500
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ParseBackend {
        id: parseBackend
    }

    Backend {
        id: backend
    }

    Database {
        id: db
        name: "project-dashboard"
        description: "Project Dashboard"

        onLoaded: {
            parseBackend.fromJSON(JSON.parse(db.get("parse", "{}")))
            settings.fromJSON(JSON.parse(db.get("settings", "{}")))
            backend.fromJSON(JSON.parse(db.get("backend", "{}")))
        }

        onSave: {
            print("Saving...")
            db.set("backend", JSON.stringify(backend.toJSON()))
            db.set("settings", JSON.stringify(settings.toJSON()))
            db.set("parse", JSON.stringify(parseBackend.toJSON()))
        }
    }

    Document {
        id: settings

        onSave: {
            settings.set("markdownCache", markdownCache)
        }
    }

    GitHub {
        id: github
    }

    Launchpad {
        id: launchpad
    }

    TravisCI {
        id: travisCI
    }

    /*!
     * Render markdown using the GitHub markdown API
     */
    function renderMarkdown(text, context) {
        if (typeof(text) != "string") {
            return ""
        } if (markdownCache.hasOwnProperty(text)) {
            /// Custom color for links
            var response = colorLinks(markdownCache[text])
            return response
        } else {
            print("Calling Markdown API")
            Http.post(github.github + "/markdown", ["access_token=" + github.oauth], function(has_error, status, response) {
                markdownCache[text] = response
                markdownCache = markdownCache
            }, undefined, undefined, JSON.stringify({
                "text": text,
                "mode": context !== undefined ? "gfm" : "markdown",
                "context": context
              }))
            return "Loading..."
        }
    }

    function colorLinks(text) {
        return text.replace(/<a(.*?)>(.*?)</g, "<a $1><font color=\"" + colors["blue"] + "\">$2</font><")
    }

    function newObject(type, args) {
        if (!args)
            args = {}
        print(type)
        var component = Qt.createComponent(type);
        if (component.errorString()) {
            print(component.errorString())
        }

        var obj = component.createObject(mainView, args);
        print("Done")
        return obj
    }

    property var markdownCache: settings.get("markdownCache", {})

    function error(title, message, action) {
        PopupUtils.open(Qt.resolvedUrl("ubuntu-ui-extras/NotifyDialog.qml"), mainView,
                        {
                            title: title,
                            text: message,
                            action:action
                        })
    }

    function friendlyTime(time) {
        var now = new Date()
        var seconds = (now - time)/1000;
        //print("Difference:", now, time, now - time)
        var minutes = Math.round(seconds/60);
        if (minutes < 1)
            return i18n.tr("Now")
        else if (minutes == 1)
            return i18n.tr("1 minute ago")
        else if (minutes < 60)
            return i18n.tr("%1 minutes ago").arg(minutes)
        var hours = Math.round(minutes/24);
        if (hours == 1)
            return i18n.tr("1 hour ago")
        else if (hours < 24)
            return i18n.tr("%1 hours ago").arg(hours)
        return Qt.formatDate(time)
    }
}
