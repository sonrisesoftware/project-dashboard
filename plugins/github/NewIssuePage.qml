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

    // FIXME: A hack to ensure that the sheet remains until after the issue is created,
    // since the sheet going away prematurely was causing the app to crash when HttpLib
    // called the callback function
    __rightButton: Button {
        objectName: "confirmButton"
        onClicked: {
            confirmClicked()
        }
    }

    property string repo
    property var action

    onConfirmClicked: createIssue()

    function createIssue() {
        busyDialog.show()
        request = github.newIssue(repo, nameField.text, descriptionField.text, function(has_error, status, response) {
            busyDialog.hide()
            if (has_error) {
                error(i18n.tr("Connection Error"), i18n.tr("Unable to create issue. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
            } else {
                PopupUtils.close(sheet)
                sheet.action()
            }
        })
    }

    TextField {
        id: nameField
        placeholderText: i18n.tr("Title")
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            //margins: units.gu(1)
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

//    tools: ToolbarItems {
//        locked: true
//        opened: true

//        back: ToolbarButton {
//            text: i18n.tr("Cancel")
//            iconSource: getIcon("back")

//            onTriggered: {
//                pageStack.pop()
//            }
//        }

//        ToolbarButton {
//            text: i18n.tr("Create")
//            iconSource: getIcon("add")

//            onTriggered: {
//                busyDialog.show()
//                request = github.newIssue(repo, nameField.text, descriptionField.text, function(has_error, status, response) {
//                    busyDialog.hide()
//                    if (has_error) {
//                        error(i18n.tr("Connection Error"), i18n.tr("Unable to create issue. Check your connection and/or firewall settings.\n\nError: %1").arg(status))
//                    } else {
//                        pageStack.pop()
//                        dialog.action()
//                    }
//                })
//            }
//        }
//    }

    property var request

    property alias busyDialog: busyDialog

    Dialog {
        id: busyDialog
        title: i18n.tr("Creating Issue")

        text: i18n.tr("Creating issue titled <b>'%1'</b>").arg(nameField.text)

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
