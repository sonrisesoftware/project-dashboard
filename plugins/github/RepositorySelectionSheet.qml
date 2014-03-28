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
import ".."

DefaultSheet {
    id: configureSheet

    title: width > units.gu(50) ? i18n.tr("Select Repository") :i18n.tr("Repository")

    contentsHeight: wideAspect ? (units.gu(6) + units.dp(2)) * 9 : mainView.height

    property GitHub plugin

    onCloseClicked: {
        plugin.project.removePlugin("GitHub")
    }

    Component.onCompleted: {
        configureSheet.__leftButton.text = i18n.tr("Cancel")
        configureSheet.__leftButton.color = "gray"
        //configureSheet.__rightButton.text = i18n.tr("Confirm")
        //configureSheet.__rightButton.color = configureSheet.__rightButton.__styleInstance.defaultColor
        configureSheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../../ubuntu-ui-extras/SuruSheetStyle.qml"), configureSheet)
    }

    ListView {
        id: repos
        model: github.repos
        clip: true

        header: Column {
            width: parent.width
            ListItem.Empty {
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
                    onAccepted: okButton.trigger()

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

                    onTriggered: {
                        plugin.doc.set("repoName", textField.text)
                        plugin.refresh()
                        PopupUtils.close(configureSheet)
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
            selected: plugin.doc.get("repoName") === modelData.full_name
            onClicked: {
                plugin.doc.set("repoName", modelData.full_name)
                plugin.refresh()
                PopupUtils.close(configureSheet)
            }
        }

        anchors {
            margins: units.gu(-1)
            fill: parent
        }
    }
}
