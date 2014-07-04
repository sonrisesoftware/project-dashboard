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
import "../model"
import "../ubuntu-ui-extras"

Page {
    title: i18n.tr("Add GitHub Project")

    ListView {
        id: repos
        model: githubPlugin.service.repos

        anchors.fill: parent

        header: Column {
            width: parent.width
            ListItem.Empty {
                TextField {
                    id: textField
                    placeholderText: i18n.tr("user/project-name")
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: okButton.left
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    onAccepted: okButton.trigger()

                    validator: RegExpValidator {
                        regExp: /.+/
                    }
                }

                Button {
                    id: okButton
                    text: i18n.tr("Add Repository")
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    enabled: textField.acceptableInput

                    onTriggered: {
                        pageStack.pop()
                        githubPlugin.addGitHubProject(textField.text)
                    }
                }
            }

            ListItem.Header {
                text: i18n.tr("Your Repositories")
            }
        }

        delegate: ListItem.Subtitled {
            text: modelData.description
            subText: modelData.full_name
            onClicked: {
                pageStack.pop()
                githubPlugin.addGitHubProject(modelData.full_name)
            }
        }
    }
}
