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
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../../backend/services"

ComposerSheet {
    id: sheet

    title: i18n.tr("New Issue")
    contentsHeight: wideAspect ? units.gu(40) : mainView.height

    Component.onCompleted: {
        sheet.__leftButton.text = i18n.tr("Cancel")
        sheet.__leftButton.color = "gray"
        sheet.__rightButton.text = i18n.tr("Create")
        sheet.__rightButton.color = sheet.__rightButton.__styleInstance.defaultColor
        sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruSheetStyle.qml"), sheet)
    }

    property string repo: plugin.repo
    property var plugin

    onConfirmClicked: plugin.newIssue(nameField.text, descriptionField.text)

    TextField {
        id: nameField
        placeholderText: i18n.tr("Title")
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

        Keys.onTabPressed: descriptionField.forceActiveFocus()
    }

    TextArea {
        id: descriptionField
        placeholderText: i18n.tr("Description")
        color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

        anchors {
            left: parent.left
            right: parent.right
            top: nameField.bottom
            bottom: parent.bottom
            topMargin: units.gu(1)
        }
    }
}
