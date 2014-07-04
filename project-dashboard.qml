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

import Ubuntu.Components 1.1
import Ubuntu.PerformanceMetrics 1.0
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import QtQuick.Window 2.0

import "ui"
import "components"
import "ubuntu-ui-extras"
import "qml-extras/promises.js" as Promise

import "udata"
import "model"
import "plugins"

MainView {
    id: app

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.mdspencer.project-dashboard"

    anchorToKeyboard: true

    automaticOrientation: true

    backgroundColor: Qt.rgba(0.3,0.3,0.3,1)

    // The size of the Nexus 4
    //width: units.gu(42)
    //height: units.gu(67)

    width: units.gu(100)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    property bool extraWideAspect: width > units.gu(120)

    property var colors: {
        "green": "#5cb85c",
        "red": "#db3131",
        "yellow": "#f0ad4e",
        "blue": "#5bc0de",
        "orange": UbuntuColors.orange,
        "default": Theme.palette.normal.baseText,
    }

    useDeprecatedToolbar: false

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

        OverviewPage {
            id: projectsPage
        }

        Component.onCompleted: {
            pageStack.push(projectsPage)

            if (settings.firstRun) {
                pageStack.push(Qt.resolvedUrl("ui/InitialWalkthrough.qml"))
            }
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
                credits[i18n.tr("Pulse icon")] = colorLinks("Icon made by <a href=\"http://www.freepik.com\" alt=\"Freepik.com\" title=\"Freepik.com\">Freepik</a> from <a href=\"http://www.flaticon.com/free-icon/pulse-line_45863\" title=\"Flaticon\">www.flaticon.com</a>")
                return credits
            }

            website: "http://www.sonrisesoftware.com/apps/project-dashboard"
            reportABug: "https://github.com/sonrisesoftware/project-dashboard/issues"

            copyright: i18n.tr("Copyright (c) 2014 Michael Spencer")
            author: "Sonrise Software"
            contactEmail: "sonrisesoftware@gmail.com"
        }
    }

    Notification {
        id: notification
    }

    function toast(text) {
        notification.show(text)
    }

//    Window {
//        id: errorsWindow
//        title: "Storage Log"

//        width: units.gu(40)
//        height: units.gu(60)

//        Rectangle {
//            anchors.fill: parent
//        }

//        ListView {
//            anchors.fill: parent
//            model: storage.debugLog

//            onCountChanged: errorsWindow.show()

//            delegate: SubtitledListItem {
//                text: modelData.title
//                subText: modelData.details

//                overlay: true
//            }
//        }

//        Label {
//            anchors.centerIn: parent
//            visible: storage.debugLog.count == 0

//            text: i18n.tr("No messages")
//            color: "gray"
//            fontSize: "large"
//            opacity: 0.8
//        }
//    }

//    Window {
//        id: objectsWindow
//        title: "uData Objects"

//        width: units.gu(40)
//        height: units.gu(60)

//        Component.onCompleted: objectsWindow.show()

//        Rectangle {
//            anchors.fill: parent
//        }

//        ListView {
//            id: docsList
//            anchors.fill: parent
//            model: storage

//            delegate: SubtitledListItem {
//                text: object._type + " " + object._id
//                visible: object._type !== 'Document'
//                height: visible ? implicitHeight : 0

//                property Document object: Document {
//                    _id: docId
//                    _db: storage
//                    _type: _get("_type", "Document")
//                }

//                overlay: true
//            }
//        }

//        Label {
//            anchors.centerIn: parent
//            visible: docsList.count == 0

//            text: i18n.tr("No objects")
//            color: "gray"
//            fontSize: "large"
//            opacity: 0.8
//        }
//    }

    Database {
        id: storage
        path: "project-dashboard.db"
        modelPath: Qt.resolvedUrl("model")
    }

    Backend {
        id: backend
        _db: storage

        availablePlugins: [notesPlugin, eventsPlugin, clickPlugin, githubPlugin]
    }

    Settings {
        id: settings
        _db: storage
    }

    NotesPlugin {
        id: notesPlugin
    }

    ClickStorePlugin {
        id: clickPlugin
    }

    EventsPlugin {
        id: eventsPlugin
    }

    GithubPlugin {
        id: githubPlugin
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
        } if (settings.markdownCache.hasOwnProperty(text)) {
            /// Custom color for links
            var response = colorLinks(settings.markdownCache[text])
            return response
        } else {
            //print("Calling Markdown API")
            Http.post(github.github + "/markdown", ["access_token=" + github.oauth], function(has_error, status, response) {
                settings.markdownCache[text] = response
                settings.markdownCache = settings.markdownCache
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

    function prompt(title, message, placeholder, value) {
        inputDialog.title = title
        inputDialog.text = message
        inputDialog.placeholderText = placeholder
        inputDialog.value = value
        inputDialog.promise = new Promise.Promise()

        inputDialog.show()

        return inputDialog.promise
    }

    function error(title, message) {
        errorDialog.title = title
        errorDialog.text = message
        errorDialog.promise = new Promise()

        errorDialog.show()

        return errorDialog.promise
    }

    InputDialog {
        id: inputDialog

        property var promise

        onAccepted: promise.resolve(value)
        onRejected: promise.rejected(value)
    }

    NotifyDialog {
        id: errorDialog

        property var promise

        onAccepted: promise.resolve()
    }

    PerformanceOverlay {
        visible: true
    }
}
