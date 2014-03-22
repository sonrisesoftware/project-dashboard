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
import "components"
import "ui"
import "backend"
import "backend/services"
import "ubuntu-ui-extras"
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
            Http.cache = db.get("httpCache", {})
            settings.fromJSON(db.get("settings", {}))
            backend.fromJSON(db.get("backend", {}))
        }

        onSave: {
            print("Saving...")
            db.set("backend", backend.toJSON())
            db.set("settings", settings.toJSON())
            db.set("httpCache", Http.cache)
        }
    }

    Document {
        id: settings

        onSave: {
            settings.set("markdownCache", markdownCache)
        }
    }

    SyncQueue {
        id: queue

        onError: {
            print("Error", status, response, args)
            mainView.error(i18n.tr("Connection Error"), i18n.tr("Unable to complete the sync opperation:\n\n%1").arg(args))
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
            var response = markdownCache[text].replace(/<a(.*?)>(.*?)</g, "<a $1><font color=\"" + colors["blue"] + "\">$2</font><")
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

    PerformanceOverlay {

    }
}
