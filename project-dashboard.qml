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

    width: units.gu(42)
    height: units.gu(67)

    property var colors: {
        "green": "#5cb85c",//"#59B159",//"#859a01",
        "red": "#db3131",//"#d9534f",//"#db3131",
        "yellow": "#f0ad4e",//"#b68b01",
        "blue": "#5bc0de",
        "default": Theme.palette.normal.baseText
    }

    property bool wideAspect: width > units.gu(80)
    property bool extraWideAspect: width > units.gu(150)
    property alias pageStack: pageStack

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

        anchors.bottomMargin: wideAspect ? -mainView.toolbar.triggerSize : 0

        Component.onCompleted: {
            if (inboxPage.count === 0)
                tabs.selectedTabIndex = 1
            pageStack.push(tabs)
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
                onClicked: PopupUtils.open(syncPopover, syncIndicator)
            }
        }
    }

    Component {
        id: syncPopover

        Popover {
            contentHeight: column.height
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
                            height: List.objectKeys(modelData.syncQueue.groups).length > 0 ? units.gu(3.5) : 0
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
