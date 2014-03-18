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

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.topMargin: -units.gu(1)
        anchors.bottomMargin: -units.gu(1)
        topMargin: units.gu(1)
        clip: true

        contentHeight: column.height
        contentWidth: column.width

        interactive: contentHeight > height - units.gu(2)

        Column {
            id: column
            width: flickable.width
            spacing: units.gu(1)
            TextField {
                id: nameField
                placeholderText: i18n.tr("Title")
                width: parent.width

                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText
                Keys.onTabPressed: descriptionField.forceActiveFocus()
            }

            Label {
                id: branchLabel
                width: parent.width

                text: i18n.tr("Branch to merge:")
            }

            OptionSelector {
                id: branchPicker
                //text: i18n.tr("Branch to merge:")
                width: parent.width

                model: {
                    var list = branches
                    print(JSON.stringify(list))
                    for (var i = 0; i < list.length; i++) {
                        if (list[i].name === "master")
                            list.splice(i, 1)
                    }
                    return list
                }

                selectedIndex: 0
                delegate: OptionSelectorDelegate {
                    text: modelData.name
                }

                onHeightChanged: {
                    print("CHANGING HEIGHT:", (branchPicker.y + branchPicker.height), flickable.height)
                    if (((branchPicker.y + branchPicker.height) > flickable.height - units.gu(2))) {
                        print("Going to expansion", flickable.height - (branchPicker.y + branchPicker.height))
                        flickable.contentY = -(flickable.height - units.gu(1)) + branchPicker.y + branchPicker.height
                    }
                }

                //style: Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruPickerStyle.qml"), branchPicker)
            }

            TextArea {
                id: descriptionField
                placeholderText: i18n.tr("Description")

                height: flickable.height - nameField.height * 2 - branchLabel.height - units.gu(6)
                width: parent.width
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText
            }
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

        text: i18n.tr("Creating pull request into <b>'%1'</b>").arg(branchPicker.model[branchPicker.selectedIndex].name)

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
