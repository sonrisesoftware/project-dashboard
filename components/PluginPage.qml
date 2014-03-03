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

Item {
    id: page
    width: 100
    height: 62

    property string title

    property list<Action> actions

    property Flickable flickable

    property int loading: plugin.loading

    onLoadingChanged: {
        if (loading > 0) {
            header.show()
        }
    }

    Item {
        anchors.fill: parent
        anchors.bottomMargin: header.height - header.__styleInstance.contentHeight
        parent: header

        ActivityIndicator {
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: (parent.height - height)/2
            }

            height: units.gu(4)
            width: height
            running: visible
            visible: loading > 0
        }
    }
}
