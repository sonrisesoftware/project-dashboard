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
import Ubuntu.PerformanceMetrics 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "components"
import "ui"
import "backend"
import "backend/services"
import "ubuntu-ui-extras"
import "ubuntu-ui-extras/listutils.js" as List
import "ubuntu-ui-extras/httplib.js" as Http
import Friends 0.2
import "Markdown.Converter.js" as Markdown

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.mdspencer.project-dashboard"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    anchorToKeyboard: true

    backgroundColor: Qt.rgba(0.3,0.3,0.3,1)

    // The size of the Nexus 4
    width: units.gu(42)
    height: units.gu(67)

    property var colors: {
        "green": "#5cb85c",//"#59B159",//"#859a01",
        "red": "#db3131",//"#d9534f",//"#db3131",
        "yellow": "#f0ad4e",//"#b68b01",
        "blue": "#5bc0de",
        "default": Theme.palette.normal.baseText,
    }

    property bool wideAspect: width > units.gu(80)
    property bool extraWideAspect: width > units.gu(150)
    //property alias pageStack: pageStack

    actions: [
        Action {
            id: settingsAction
            text: i18n.tr("Settings")
            iconSource: getIcon("settings")
            onTriggered: pageStack.push(Qt.resolvedUrl("ui/SettingsPage.qml"))
        }
    ]

    PageStack {
        id: pageStack

        Tabs {
            id: tabs
            Tab {
                title: page.title
                page: UniversalInboxPage {
                    id: inboxPage
                }
            }

            Tab {
                title: page.title
                page: ProjectsPage {
                    id: projectsPage
                }
            }
        }

        anchors.bottomMargin: wideAspect && mainView.toolbar.opened && mainView.toolbar.locked ? -mainView.toolbar.triggerSize : 0

        Component.onCompleted: {
            if (inboxPage.count === 0)
                tabs.selectedTabIndex = 1
            pageStack.push(tabs)

            if (!settings.get("existingInstallation", false)) {
                pageStack.push(walkthrough)
            }
        }
    }

    Component {
        id: walkthrough
        Walkthough {
            appName: "Project Dashboard"
            onFinished: {
                settings.set("existingInstallation", true)
                pageStack.pop()
            }

            model: [
                 Component {
                    Item {
                        Image {
                            anchors {
                                bottom: welcomeColumn.top
                                bottomMargin: units.gu(4)
                                horizontalCenter: parent.horizontalCenter
                            }
                            fillMode: Image.PreserveAspectFit
                            width: units.gu(11)
                            source: Qt.resolvedUrl("project-dashboard-shadowed.png")
                        }

                        Column {
                            id: welcomeColumn
                            anchors {
                                centerIn: parent
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                fontSize: "large"
                                text: i18n.tr("Welcome to")
                            }

                            Label {
                                fontSize: "x-large"
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("Project Dashboard")
                            }
                        }

                        Label {
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            text: i18n.tr("Swipe left to continue")
                        }
                    }
                },

                Component {
                   Item {
                       Label {
                           id: headerLabel
                           anchors.horizontalCenter: parent.horizontalCenter
                           fontSize: "x-large"
                           text: i18n.tr("Project Dashboard")
                       }

                       Label {
                           id: contentsLabel
                           anchors {
                               top: headerLabel.bottom
                               topMargin: units.gu(2)
                           }

                           width: parent.width
                           font.pixelSize: units.dp(17)
                           wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                           horizontalAlignment: Text.AlignHCenter
                           text: i18n.tr("Project Dashboard helps you manage everything about your projects in one convienent app.  " +
                                         "Add plugins to track upcoming dates, keep notes, track time, manage to dos, and much more.")
                       }

                       Image {
                           fillMode: Image.PreserveAspectFit
                           width: parent.width
                           source: Qt.resolvedUrl("walkthrough-plugins.png")
                           smooth: true
                           antialiasing: true


                           anchors {
                               top: contentsLabel.bottom
                               bottom: parent.bottom
                               topMargin: units.gu(2)
                           }
                       }
                   }
               },

               Component {
                    Item {
                        Label {
                            id: headerLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            fontSize: "x-large"
                            text: i18n.tr("Use Cases")
                        }

                        Label {
                            id: contentsLabel
                            anchors {
                                top: headerLabel.bottom
                                topMargin: units.gu(2)
                            }

                            width: parent.width
                            font.pixelSize: units.dp(17)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("There are many uses for Project Dashboard. Here are a few ideas to help you get started:")
                        }

                        Label {
                            id: list
                            anchors {
                                top: contentsLabel.bottom
                                topMargin: units.gu(2)
                                left: parent.left
                                right: parent.right
                                leftMargin: units.gu(-1.5)
                            }

                            font.pixelSize: units.dp(17)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: i18n.tr("<ul>" +
                                          "<li>Managing a software project hosted on GitHub</li>" +
                                          "<li>Working as a hourly contractor</li>" +
                                          "<li>Planning an upcoming family reunion, wedding or other event</li>" +
                                          "<li>Keeping track of a class or project</li>" +
                                          "<li>And lots more...</li>" +
                                          "</ul>")
                            textFormat: Text.RichText
                        }

//                        Label {
//                            anchors {
//                                top: list.bottom
//                                topMargin: units.gu(2)
//                            }

//                            width: parent.width
//                            //font.pixelSize: units.dp(17)
//                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                            horizontalAlignment: Text.AlignHCenter
//                            text: i18n.tr("To decide if Project Dashboard is right for managing your project, just ask yourself the question \"Would I rather go to different apps to manage my project or would I rather have everything in one place?\"")
//                        }
                    }
               },

               Component {
                   Item {
                       Label {
                           id: headerLabel
                           anchors.horizontalCenter: parent.horizontalCenter
                           fontSize: "x-large"
                           text: i18n.tr("Inbox")
                       }

                       Label {
                           id: contentsLabel
                           anchors {
                               top: headerLabel.bottom
                               topMargin: units.gu(2)
                           }

                           width: parent.width
                           font.pixelSize: units.dp(17)
                           wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                           horizontalAlignment: Text.AlignHCenter
                           text: i18n.tr("If you have projects that are connected to online services, such as GitHub, " +
                                         "new notifications will show up in your project's inbox and also the global inbox.")
                       }

                       Item {
                           anchors {
                               top: contentsLabel.bottom
                               bottom: parent.bottom
                               topMargin: units.gu(2)
                           }

                           width: parent.width


                           AwesomeIcon {
                               color: "#d9534f"
                               name: "bell"
                               size: units.gu(9)
                               anchors.centerIn: parent
                           }
                       }
                   }
                },

                Component {
                    Item {
                        Label {
                            id: headerLabel
                            anchors.horizontalCenter: parent.horizontalCenter
                            fontSize: "x-large"
                            text: i18n.tr("Pulse")
                        }

                        Label {
                            id: contentsLabel
                            anchors {
                                top: headerLabel.bottom
                                topMargin: units.gu(2)
                            }

                            width: parent.width
                            font.pixelSize: units.dp(17)
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: Text.AlignHCenter
                            text: i18n.tr("The Pulse tab shows you relevent content from your project's plugins, such as issues or bugs assigned to you, the current time you've tracked today, your next event, or upcoming to dos.")
                        }

                        Item {
                            anchors {
                                top: contentsLabel.bottom
                                bottom: parent.bottom
                                topMargin: units.gu(2)
                            }

                            width: parent.width


                            AwesomeIcon {
                                name: "dashboard"
                                size: units.gu(9)
                                anchors.centerIn: parent
                            }
                        }
                    }
                },

                Component {
                    Item {
                        Column {
                            width: parent.width

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Enjoy!"
                                fontSize: "x-large"
                            }
                        }

                        Column {
                            id: welcomeColumn
                            anchors {
                                centerIn: parent
                            }
                            spacing: units.gu(1)

                            Image {
                                anchors {
                                    //bottom: welcomeColumn.top
                                    //bottomMargin: units.gu(2)
                                    horizontalCenter: parent.horizontalCenter
                                }
                                fillMode: Image.PreserveAspectFit
                                width: units.gu(11)
                                source: Qt.resolvedUrl("project-dashboard-shadowed.png")
                            }

                            Item {
                                width: parent.width
                                height: units.gu(1)
                            }

                            Label {
                                fontSize: "x-large"
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: i18n.tr("Project Dashboard")
                            }

                            Label {
                                fontSize: "large"
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                                text: i18n.tr("Manage everything about your projects, in one convenient app")
                            }
                        }

                        Button {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                            }

                            height: units.gu(5)
                            width: units.gu(30)

                            text: i18n.tr("Start using Project Dashboard!")
                            color: colors["green"]
                            onTriggered: {
                                settings.set("existingInstallation", true)
                                pageStack.pop()
                            }
                        }
                    }
                }
            ]
        }
    }

    Component {
        id: aboutPage
        AboutPage {

            linkColor: colors["blue"]

            appName: i18n.tr("Project Dashboard")
            icon: Qt.resolvedUrl("project-dashboard-shadowed.png")
            iconFrame: false
            version: "@APP_VERSION@"
            credits: {
                var credits = {}
                credits[i18n.tr("Icon")] = "Sam Hewitt"
                credits[i18n.tr("Debian Packaging")] = "Nekhelesh Ramananthan"
                return credits
            }

            website: "http://www.sonrisesoftware.com/apps/project-dashboard"
            reportABug: "https://github.com/iBeliever/project-dashboard/issues"

            copyright: i18n.tr("Copyright (c) 2014 Michael Spencer")
            author: "Sonrise Software"
            contactEmail: "sonrisesoftware@gmail.com"
        }
    }

    property bool syncError: false
    property bool busy: List.iter(backend.projects, function(project) {
        return project.syncQueue.count
    }) > 0

    Item {
        anchors.fill: parent
        anchors.bottomMargin: header.height - header.__styleInstance.contentHeight
        parent: header

        AwesomeIcon {
            name: "exclamation-triangle"
            color: colors["yellow"]
            anchors.centerIn: syncIndicator
            size: units.gu(2.6)
            opacity: !busy && syncError ? 1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.SlowDuration
                }
            }
        }

        ActivityIndicator {
            id: syncIndicator
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: (parent.height - height)/2
            }

            height: units.gu(4)
            width: height
            running: opacity > 0
            opacity: busy ? 1 : 0

            Behavior on opacity {
                UbuntuNumberAnimation {
                    duration: UbuntuAnimation.SlowDuration
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: busy || syncError
                onClicked: PopupUtils.open(syncPopover, syncIndicator)
            }
        }
    }

    Component {
        id: syncPopover

        Popover {
            id: popover
            contentHeight: column.height

            onContentHeightChanged: {
                if (contentHeight == 0)
                    PopupUtils.close(popover)
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
                            Label {
                                text: modelData.name
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: units.gu(1)
                                }
                                color: "#888888"//Theme.palette.normal.overlayText
                            }
                            height: List.objectKeys(modelData.syncQueue.groups).length > 0 ? units.gu(4) : 0
                        }

                        Repeater {
                            model: List.objectKeys(modelData.syncQueue.groups)
                            delegate: SubtitledListItem {
                                id: item
                                overlay: true
                                property var group: syncColumn.project.syncQueue.groups[modelData]
                                text: group.title
                                subText: group.errors.length > 0 ? i18n.tr("Error: %1").arg(group.errors[0].status)
                                                                 : ""

                                control: ProgressBar {
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
                                        UbuntuNumberAnimation {
                                            duration: UbuntuAnimation.SlowDuration
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    FriendsUtils {
        id: friendsUtils
    }

    Backend {
        id: backend
    }

    Database {
        id: db
        path: "project-dashboard.db"

        onLoaded: {
            settings.fromJSON(db.get("settings", {}))
            backend.fromJSON(db.get("backend", {}))
        }

        onSave: {
            print("Saving...")
            db.set("backend", backend.toJSON())
            db.set("settings", settings.toJSON())
        }
    }

    Document {
        id: settings

        onSave: {
            settings.set("markdownCache", markdownCache)
        }
    }

//    SyncQueue {
//        id: queue

//        onError: {
//            print("Error", call, status, response, args)
//            if (status === 0) {
//                mainView.error(i18n.tr("Connection Error"), i18n.tr("Timeout error. Please check your internet and firewall settings:\n\n%1").arg(call))
//            } else {
//                if (args) {
//                    mainView.error(i18n.tr("Connection Error"), i18n.tr("Unable to complete action:\n\n%1").arg(args))
//                } else {
//                    mainView.error(i18n.tr("Connection Error"), i18n.tr("Unable to complete operation. HTTP Error: %1\n\n%2").arg(status).arg(call))
//                }
//            }
//        }
//    }

    GitHub {
        id: github
    }

    Launchpad {
        id: launchpad
    }

    TravisCI {
        id: travisCI
    }

    function getIcon(name) {
        var mainView = "icons/"
        var ext = ".png"

        //return "image://theme/" + name

        if (name.indexOf(".") === -1)
            name = mainView + name + ext
        else
            name = mainView + name

        return Qt.resolvedUrl(name)
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
        return component.createObject(mainView, args);
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
