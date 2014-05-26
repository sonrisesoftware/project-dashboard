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

import "../ubuntu-ui-extras"
import "../components"

Page {
    id: page
    
    title: i18n.tr("Settings")

    ColumnFlow {
        id: column
        anchors.fill: parent
        anchors.margins: units.gu(1)
        columns: extraWideAspect ? 3 : wideAspect ? 2 : 1

        Timer {
            interval: 100
            running: true
            onTriggered: {
                //print("Triggered!")
                column.reEvalColumns()
            }
        }

        Repeater {
            model: backend.availableServices
            delegate: GridTile {
                title: i18n.tr("%1 Account").arg(modelData.title)
                iconSource: modelData.icon

                Loader {
                    width: parent.width
                    sourceComponent: modelData.accountItem
                }

                ListItem.Empty {
                    height: _desc.height + units.gu(2)
                    Label {
                        id: _desc
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            right: parent.right
                            margins: units.gu(2)
                        }
                        text: modelData.description
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    visible: !modelData.enabled
                }

                ListItem.Standard {
                    Label {
                       anchors.centerIn: parent
                       text: modelData.enabled ? i18n.tr("Log out of this account") : i18n.tr("Log in to %1").arg(modelData.title)
                    }

                    onClicked: {
                        if (modelData.enabled)
                            modelData.revoke()
                        else
                            modelData.authenticate()
                    }

                    showDivider: false
                }

                visible: modelData.authenticationRequired
            }
        }

        GridTile {
            title: "Help and About"
            iconSource: "question-circle"

            ListItem.Standard {
                text: i18n.tr("About Project Dashboard")
                progression: true
                onClicked: pageStack.push(aboutPage)
            }

            ListItem.Standard {
                text: i18n.tr("View Tutorial")
                progression: true
                onClicked: pageStack.push(Qt.resolvedUrl("InitialWalkthrough.qml"), {exitable: true})
            }
        }
    }

    tools: ToolbarItems {
        opened: wideAspect
        locked: wideAspect

        onLockedChanged: opened = locked
    }
}
