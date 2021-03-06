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
import ".."
import "../../ubuntu-ui-extras"

Dialog {
    id: addLinkDialog

    title: i18n.tr("Add Link")
    text: i18n.tr("Enter the link you want to save in Resources:")

    property Resources plugin

    property alias url: textField.text

    TextField {
        id: titleField

        placeholderText: i18n.tr("Title")

        onAccepted: textField.forceActiveFocus()
        Keys.onTabPressed: textField.forceActiveFocus()
        style: DialogTextFieldStyle {}
    }

    TextField {
        id: textField

        placeholderText: i18n.tr("http://www.example.com")

        onAccepted: okButton.clicked()
        style: DialogTextFieldStyle {}
        validator: RegExpValidator {
            regExp: /.+/
        }
    }

    Item {
        width: parent.width
        height: childrenRect.height

        Button {
            objectName: "cancelButton"
            text: i18n.tr("Cancel")

            anchors {
                left: parent.left
                right: parent.horizontalCenter
                rightMargin: units.gu(1)
            }

            color: "gray"

            onClicked: {
                PopupUtils.close(addLinkDialog)
            }
        }

        Button {
            id: okButton
            objectName: "okButton"

            anchors {
                left: parent.horizontalCenter
                right: parent.right
                leftMargin: units.gu(1)
            }

            text: i18n.tr("Ok")
            enabled: textField.acceptableInput

            onClicked: {
                PopupUtils.close(addLinkDialog)
                var link = textField.text
                if (link.indexOf("http") !== 0) {
                    link = "http://" + link
                }

                plugin.documents.push({"title": titleField.text, "type": "link", "text": link})
                plugin.documents = plugin.documents
                notification.show(i18n.tr("Resource saved"))
            }
        }
    }
}
