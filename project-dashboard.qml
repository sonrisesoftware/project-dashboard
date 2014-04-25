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

import "qml-air"
import "qml-air/ListItems" as ListItem
import "qml-extras"
import "qml-extras/listutils.js" as List
import "qml-extras/httplib.js" as Http

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

    initialPage: tabs

    Tabs {
        id: tabs

        title: "Project Dashboard"

        leftWidgets: Button {
            style: "primary"
            text: "New Project"
            onClicked: newSheet.open()
        }

        rightWidgets: [
            Button {
                iconName: syncError ? "exclamation-triangle" : "spinner-rotate"
                iconColor: syncError ? theme.danger : textColor
                text: syncError ? "Sync error" : "Syncing..."
                opacity: busy ? 1 : 0

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            },

            Button {
                iconName: "user"
                onClicked: userPopover.open(caller)
            },

            Button {
                iconName: "cog"
                onClicked: configMenu.open(caller)
            }
        ]

        UniversalInboxPage {
            id: inboxPage
        }

        ProjectsPage {
            id: projectsPage
        }

        Component.onCompleted: {
            if (inboxPage.count == 0)
                tabs.selectedPage = projectsPage
        }
    }

    InputDialog {
        id: newSheet

        title: i18n.tr("Create New Project")
        text: i18n.tr("Please enter a name for your new project.")
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

//    Component {
//        id: aboutPage
//    }

    property bool syncError: List.iter(backend.projects, function(project) {
        return project.syncQueue.hasError
    }) > 0
    property bool busy: List.iter(backend.projects, function(project) {
        return project.syncQueue.count
    }) > 0

//    Item {
//        anchors.fill: parent
//        anchors.bottomMargin: header.height - header.__styleInstance.contentHeight
//        parent: header

//        AwesomeIcon {
//            name: "exclamation-triangle"
//            color: colors["yellow"]
//            anchors.centerIn: syncIndicator
//            size: units.gu(2.6)
//            opacity: !busy && syncError ? 1 : 0

//            Behavior on opacity {
//                UbuntuNumberAnimation {
//                    duration: UbuntuAnimation.SlowDuration
//                }
//            }
//        }

//        ActivityIndicator {
//            id: syncIndicator
//            anchors {
//                right: parent.right
//                verticalCenter: parent.verticalCenter
//                rightMargin: (parent.height - height)/2
//            }

//            height: units.gu(4)
//            width: height
//            running: opacity > 0
//            opacity: busy ? 1 : 0

//            Behavior on opacity {
//                UbuntuNumberAnimation {
//                    duration: UbuntuAnimation.SlowDuration
//                }
//            }

//            MouseArea {
//                anchors.fill: parent
//                enabled: busy || syncError
//                onClicked: PopupUtils.open(syncPopover, syncIndicator)
//            }
//        }
//    }

//    Component {
//        id: syncPopover

//        Popover {
//            id: popover
//            contentHeight: column.height

//            onContentHeightChanged: {
//                if (contentHeight == 0)
//                    PopupUtils.close(popover)
//            }

//            Column {
//                id: column
//                width: parent.width

//                Repeater {
//                    model: backend.projects
//                    delegate: Column {
//                        id: syncColumn
//                        width: parent.width

//                        property Project project: modelData

//                        visible: List.objectKeys(modelData.syncQueue.groups).length > 0

//                        ListItem.Header {
//                            Label {
//                                text: modelData.name
//                                anchors {
//                                    verticalCenter: parent.verticalCenter
//                                    left: parent.left
//                                    leftMargin: units.gu(1)
//                                }
//                                color: "#888888"//Theme.palette.normal.overlayText
//                            }
//                            height: List.objectKeys(modelData.syncQueue.groups).length > 0 ? units.gu(4) : 0
//                        }

//                        Repeater {
//                            model: List.objectKeys(modelData.syncQueue.groups)
//                            delegate: SubtitledListItem {
//                                id: item
//                                overlay: true
//                                property var group: syncColumn.project.syncQueue.groups[modelData]
//                                text: group.title
//                                subText: group.errors.length > 0 ? i18n.tr("Error: %1").arg(group.errors[0].status)
//                                                                 : ""

//                                onClicked: {
//                                    print("Clicked")
//                                    error(i18n.tr("%1 Failed").arg(group.title), i18n.tr("Call: %1\n\n%2").arg(group.errors[0].call).arg(group.errors[0].response))
//                                }

//                                ProgressBar {
//                                    anchors {
//                                        right: parent.right
//                                        verticalCenter: parent.verticalCenter
//                                        rightMargin: units.gu(2)
//                                    }
//                                    minimumValue: 0
//                                    maximumValue: group.total
//                                    value: item.group.total - item.group.count
//                                    visible: item.group.count > 0
//                                    width: units.gu(10)
//                                    height: units.gu(2.5)
//                                }

//                                AwesomeIcon {
//                                    name: "exclamation-triangle"
//                                    color: colors["yellow"]
//                                    anchors {
//                                        right: parent.right
//                                        verticalCenter: parent.verticalCenter
//                                        rightMargin: (parent.height - height)/2
//                                    }
//                                    size: units.gu(2.6)
//                                    opacity: item.group.errors.length > 0 ? 1 : 0

//                                    Behavior on opacity {
//                                        UbuntuNumberAnimation {
//                                            duration: UbuntuAnimation.SlowDuration
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }

    Account {
        id: account
        signedIn: true
        name: "Michael Spencer"
        email: "sonrisesoftware@gmail.com"
    }

    Backend {
        id: backend
    }

    Database {
        id: db
        name: "project-dashboard"
        description: "Project Dashboard"

        onLoaded: {
            settings.fromJSON(JSON.parse(db.get("settings", "{}")))
            backend.fromJSON(JSON.parse(db.get("backend", "{}")))
        }

        onSave: {
            print("Saving...")
            db.set("backend", JSON.stringify(backend.toJSON()))
            db.set("settings", JSON.stringify(settings.toJSON()))
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
}
