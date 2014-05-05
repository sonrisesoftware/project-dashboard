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
import "../../qml-air"
import "../../backend/services"

Sheet {
    id: sheet

    title: i18n.tr("New Issue")
    Component.onCompleted: {
        sheet.__rightButton.text = i18n.tr("Create")
    }


    property string repo: plugin.repo
    property var plugin

    onAccepted: plugin.newIssue(nameField.text, descriptionField.text)

    TextField {
        id: nameField
        placeholderText: i18n.tr("Title")
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        Keys.onTabPressed: descriptionField.forceActiveFocus()
    }

    TextArea {
        id: descriptionField
        placeholderText: i18n.tr("Description")

        anchors {
            left: parent.left
            right: parent.right
            top: nameField.bottom
            bottom: parent.bottom
            topMargin: units.gu(1)
        }
    }
}
