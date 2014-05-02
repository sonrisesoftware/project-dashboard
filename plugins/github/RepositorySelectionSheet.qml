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
import "../../qml-air/ListItems" as ListItem
import ".."
import "../../components"

Sheet {
    id: configureSheet

    title: width > units.gu(50) ? i18n.tr("Select Repository") :i18n.tr("Repository")

    confirmButton: false
    height: (units.gu(5)) * 9
    margins: 0

    property GitHub plugin

    Component.onCompleted: __leftButton.text = "Cancel"

    onAccepted: {
        plugin.project.removePlugin("GitHub")
    }

    ListView {
        id: repos
        model: github.repos
        clip: true

        header: Column {
            width: parent.width
            ListItem.BaseListItem {
                height: units.gu(5)
                TextField {
                    id: textField
                    placeholderText: i18n.tr("Repository name")
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(2)
                        right: okButton.left
                        rightMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    onTriggered: okButton.clicked()

                    validator: RegExpValidator {
                        regExp: /.+/
                    }
                }

                Button {
                    id: okButton
                    text: i18n.tr("Use")
                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }

                    enabled: textField.acceptableInput

                    onClicked: {
                        plugin.doc.set("repoName", textField.text)
                        plugin.refresh()
                        configureSheet.close()
                    }
                }
            }

            ListItem.Header {
                text: i18n.tr("Your Repositories")
            }
        }

        delegate: SubtitledListItem {
            text: modelData.description
            subText: modelData.full_name
            selected: plugin.doc.get("repoName") === modelData.full_name
            onClicked: {
                plugin.doc.set("repoName", modelData.full_name)
                plugin.refresh()
                configureSheet.close()
            }
        }

        anchors {
            fill: parent
        }
    }
}
