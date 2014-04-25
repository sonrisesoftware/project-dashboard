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
import "../backend"
import "../components"

import "../qml-air"
import "../qml-air/ListItems" as ListItem

Sheet {
    id: page
    
    title: i18n.tr("Project Configuration")

    confirmButton: false

    property Project project

    margins: 0
    Flickable {
        id: flickable
        anchors.fill: parent

        contentWidth: width
        contentHeight: column.height
        clip: true

        Column {
            id: column
            width: parent.width

            ListItem.Standard {
                text: i18n.tr("Name")
                height: units.gu(6)
                highlightable: false

                TextField {
                    text: project.name
                    Component.onDestruction: {
                        print("Destroying")
                        project.name = text
                    }

                    anchors {
                        right: parent.right
                        rightMargin: units.gu(2)
                        verticalCenter: parent.verticalCenter
                    }
                }
            }

            ListItem.Header {
                text: i18n.tr("Plugins")
            }

            Repeater {
                model: backend.availablePlugins

                delegate: ListItem.Standard {
                    id: listItem

                    enabled: type != ""
                    height: units.gu(5)
                    highlightable: false

                    Switch {
                        checked: project.hasPlugin(type)
                        onCheckedChanged: {
                            project.enablePlugin(type, checked)
                            checked = Qt.binding(function () {return project.hasPlugin(type)})
                        }

                        anchors {
                            right: parent.right
                            rightMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    property bool overlay: false

                    AwesomeIcon {
                        id: iconItem
                        name: model.icon
                        size: units.gu(3.5)
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: units.gu(1.5)
                        }
                    }

                    Column {
                        id: labels

                        spacing: units.gu(0.1)

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: iconItem.right
                            leftMargin: units.gu(1.5)
                            rightMargin: units.gu(2)
                            right: parent.right
                        }

                        Label {
                            id: titleLabel

                            width: parent.width
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            text: title
                        }

                        Label {
                            id: subLabel
                            width: parent.width

                            height: visible ? implicitHeight: 0
                            //color:  Theme.palette.normal.backgroundText
                            maximumLineCount: 1
                            opacity: overlay ? 0.7 : 0.65
                            font.weight: Font.Light
                            fontSize: "small"
                            visible: text !== ""
                            elide: Text.ElideRight
                            text: project.hasPlugin(type) ? project.getPlugin(type).configuration : ""
                            color: theme.secondaryColor
                        }
                    }
                }
            }

            Repeater {
                model: backend.availableServices

                delegate: ListItem.Standard {
                    id: listItem

                    highlightable: false

                    property alias text: titleLabel.text
                    property alias subText: subLabel.text
                    height: units.gu(5)

                    Switch {
                        enabled: modelData.isEnabled(project) === ""
                        onEnabledChanged: {
                            if (!enabled)
                                project.enablePlugin(modelData.type, false)
                        }

                        checked: project.hasPlugin(modelData.type)
                        onCheckedChanged: {
                            project.enablePlugin(modelData.type, checked)
                            checked = Qt.binding(function () {return project.hasPlugin(modelData.type)})
                        }

                        anchors {
                            right: parent.right
                            rightMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }

                    property bool overlay: false

                    AwesomeIcon {
                        id: icon2
                        name: modelData.icon
                        size: units.gu(3.5)
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: units.gu(1.5)
                        }
                    }

                    Column {

                        spacing: units.gu(0.1)

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: icon2.right
                            leftMargin: units.gu(1.5)
                            rightMargin: units.gu(2)
                            right: parent.right
                        }

                        Label {
                            id: titleLabel

                            width: parent.width
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            text: modelData.title
                        }

                        Label {
                            id: subLabel
                            width: parent.width

                            height: visible ? implicitHeight: 0
                            //color:  Theme.palette.normal.backgroundText
                            maximumLineCount: 1
                            opacity: overlay ? 0.7 : 0.65
                            font.weight: Font.Light
                            fontSize: "small"
                            visible: text !== ""
                            elide: Text.ElideRight
                            text: modelData.isEnabled(project) === "" ? project.hasPlugin(modelData.type) ? project.getPlugin(modelData.type).configuration
                                                                                                          : ""
                                                                      : modelData.isEnabled(project)
                            color: theme.secondaryColor
                        }
                    }
                }
            }

            ListItem.BaseListItem {
                height: textLabel.height + units.gu(2)
                Label {
                    id: textLabel

                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    text: "Looking for more plugins or cloud syncronization?\nCreate a PRO account now!"

                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                        margins: units.gu(2)
                    }
                }
            }
        }

    }

    ScrollBar {
        flickableItem: flickable
    }
}
