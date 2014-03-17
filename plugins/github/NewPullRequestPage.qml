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
import Ubuntu.Components.Pickers 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import "../../backend/services"

ComposerSheet {
    id: sheet

    title: i18n.tr("New Pull Request")

    Component.onCompleted: {
        sheet.__leftButton.text = i18n.tr("Cancel")
        sheet.__leftButton.color = "gray"
        sheet.__rightButton.text = i18n.tr("Create")
        sheet.__rightButton.color = sheet.__rightButton.__styleInstance.defaultColor
        sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruSheetStyle.qml"), sheet)
    }

    // FIXME: A hack to ensure that the sheet remains until after the issue is created,
    // since the sheet going away prematurely was causing the app to crash when HttpLib
    // called the callback function
    __rightButton: Button {
        objectName: "confirmButton"
        onClicked: {
            confirmClicked()
        }
    }

    onConfirmClicked: createPullRequest()

    property string repo
    property var action
    property var branches

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

    Label {
        id: branchLabel
        anchors {
            top: nameField.bottom
            left: parent.left//branchLabel.right
            //right: parent.right
            //leftMargin: units.gu(1)
            topMargin: units.gu(1)
        }

        text: i18n.tr("Branch to merge:")
    }

    OptionSelector {
        id: branchPicker
        //text: i18n.tr("Branch to merge:")
        anchors {
            top: branchLabel.bottom
            left: parent.left//branchLabel.right
            right: parent.right
            //leftMargin: units.gu(1)
            topMargin: units.gu(1)
        }

        model: {
            var list = branches
            print(JSON.stringify(list))
            for (var i = 0; i < list.length; i++) {
                if (list[i].name === "master")
                    list.splice(i, 1)
            }
            return list
        }

        width: units.gu(20)
        selectedIndex: 0
        delegate: OptionSelectorDelegate {
            text: modelData.name
        }

        //style: Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruPickerStyle.qml"), branchPicker)
    }

    TextArea {
        id: descriptionField
        placeholderText: i18n.tr("Description")

        anchors {
            left: parent.left
            right: parent.right
            top: branchPicker.bottom
            bottom: parent.bottom
            topMargin: units.gu(1)
        }
    }

    function createPullRequest() {
        busyDialog.show()
        request = github.newPullRequest(repo, nameField.text, descriptionField.text, branchPicker.model[branchPicker.selectedIndex].name, function(has_error, status, response) {
            busyDialogAlias.hide()
            if (has_error) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to create pull request. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            } else {
                PopupUtils.close(sheet)
                sheet.action()
            }
        })
    }

    property var request

    property alias busyDialogAlias: busyDialog

    Dialog {
        id: busyDialog
        title: i18n.tr("Creating Pull Request")

        text: i18n.tr("Creating pull request for <b>'%1'</b>").arg(branchPicker.selectedValue)

        ActivityIndicator {
            running: busyDialog.visible
            implicitHeight: units.gu(5)
            implicitWidth: implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: i18n.tr("Cancel")
            onTriggered: {
                request.abort()
                busyDialog.hide()
            }
        }
    }
}
