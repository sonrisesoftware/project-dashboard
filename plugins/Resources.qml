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
import "../backend"
import "../components"
import "../backend/services"
import "../ubuntu-ui-extras"
import "github"

Plugin {
    id: plugin

    title: "Resources"
    iconSource: "file"

    property var documents: doc.get("resources", [])

    action: Action {
        text: i18n.tr("Add")
        onTriggered: PopupUtils.open(addPopover, value)
    }

    document: Document {
        id: doc
        docId: backend.getPlugin("resources").docId
        parent: project.document
    }

    ListItem.Header {
        text: i18n.tr("Recently Saved")
    }

    Repeater {
        model: Math.min(documents.length, 4)
        delegate: ListItem.Subtitled {
            property var modelData: documents[documents.length - index - 1]
            text: modelData.title
            subText: modelData.text

            onClicked: pageStack.push(Qt.resolvedUrl("resources/WebPage.qml"), {resource: modelData})
        }
    }

    viewAllMessage: i18n.tr("View all resources")
    summary: i18n.tr("<b>%1</b> resources").arg(documents.length)

    Component {
        id: addPopover

        ActionSelectionPopover {
            actions: ActionList {
                Action {
                    text: i18n.tr("Link")
                    onTriggered: PopupUtils.open(addLinkDialog)
                }

                Action {
                    text: i18n.tr("Content from other apps")
                }
            }
        }
    }

    Component {
        id: addLinkDialog

        Dialog {
            id: root

            title: i18n.tr("Add Link")
            text: i18n.tr("Enter the link you want to save in Resources:")

            TextField {
                id: titleField

                placeholderText: i18n.tr("Title")

                onAccepted: textField.forceActiveFocus()
            }

            TextField {
                id: textField

                placeholderText: i18n.tr("Link")

                onAccepted: okButton.clicked()
                validator: RegExpValidator {
                    regExp: /.+/
                }
            }

            Button {
                id: okButton
                objectName: "okButton"

                text: i18n.tr("Ok")
                enabled: textField.acceptableInput

                onClicked: {
                    PopupUtils.close(root)
                    documents.push({"title": titleField.text, "type": "link", "text": textField.text})
                    doc.set("resources", documents)
                }
            }

            Button {
                objectName: "cancelButton"
                text: i18n.tr("Cancel")

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "gray"
                    }

                    GradientStop {
                        position: 1
                        color: "lightgray"
                    }
                }

                onClicked: {
                    PopupUtils.close(root)
                }
            }
        }
    }
}
