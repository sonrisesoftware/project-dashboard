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

import "ui"

import "udata"
import "model"
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
    //width: units.gu(42)
    //height: units.gu(67)

    width: units.gu(100)
    height: units.gu(75)

    property var colors: {
        "green": "#5cb85c",
        "red": "#db3131",
        "yellow": "#f0ad4e",
        "blue": "#5bc0de",
        "default": Theme.palette.normal.baseText,
    }

    property bool wideAspect: width > units.gu(80)
    property bool extraWideAspect: width > units.gu(150)
    //property alias pageStack: pageStack

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

        ProjectsPage {
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

    Database {
        id: storage
        path: "project-dashboard.db"
        modelPath: Qt.resolvedUrl("model")
    }

    Backend {
        id: backend
        _db: storage
    }

    Settings {
        id: settings
        _db: storage
    }

    GitHub {
        id: github
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
            print("Calling Markdown API")
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

    function newObject(type, args) {
        if (!args)
            args = {}
        print(type)
        var component = Qt.createComponent(type);
        return component.createObject(mainView, args);
    }

    function error(title, message, action) {
        PopupUtils.open(Qt.resolvedUrl("ubuntu-ui-extras/NotifyDialog.qml"), mainView,
                        {
                            title: title,
                            text: message,
                            action:action
                        })
    }
}
