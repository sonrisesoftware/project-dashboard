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
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Extras.Browser 0.1

Page {
    id: webPage

    title: resource.title

    property var resource

    property string token: ""
    property string firstGet: "?access_token=" + token
    property string otherGet: "&access_token=" + token

    actions: [
        Action {
            id: bookmarkAction
            text: i18n.tr("Bookmark")
            iconSource: getIcon("favorite-unselected")
            enabled: webView.url != resource.text
            onTriggered: {
                onTriggered: PopupUtils.open(addLinkDialog, webPage, {url: webView.url})
            }
        }

    ]


    UbuntuWebView {
        id: webView
        //the webview is bugged, anchors.fill: parent doesn't work
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height

        url: resource.text

        onLoadingChanged: {
            if (loadRequest.status === UbuntuWebView.LoadFailedStatus) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to authenticate to GitHub. Check your connection and/or firewall settings."), pageStack.pop)
            }
        }

    }

    UbuntuShape {
        anchors.centerIn: parent
        width: column.width + units.gu(4)
        height: column.height + units.gu(4)
        color: Qt.rgba(0.2,0.2,0.2,0.8)

        opacity: webView.loading ? 1 : 0

        Behavior on opacity {
            UbuntuNumberAnimation {
                duration: UbuntuAnimation.SlowDuration
            }
        }

        Column {
            id: column
            anchors.centerIn: parent
            spacing: units.gu(1)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: "large"
                text: webView.loading ? i18n.tr("Loading web page...")
                                      : i18n.tr("Success!")
            }

            ProgressBar {
                anchors.horizontalCenter: parent.horizontalCenter

                width: units.gu(30)
                maximumValue: 100
                minimumValue: 0
                value: webView.loadProgress
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked

        ToolbarButton {
            action: bookmarkAction
        }
    }
}

