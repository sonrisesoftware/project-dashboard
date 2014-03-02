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

    Column {
        id: column
        anchors.centerIn: parent
        visible: webView.loading
        spacing: units.gu(1)

        ActivityIndicator {
            running: column.visible
            implicitHeight: units.gu(5)
            implicitWidth: implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            fontSize: "large"
            text: i18n.tr("Loading (%1%)").arg(webView.loadProgress)
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }
}

