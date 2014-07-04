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
import "../components"
import "../ubuntu-ui-extras"

Item {
    height: visible ? tile.implicitHeight + tile.anchors.margins * 2 : 0

    visible: column.height > 0

    property alias title: titleLabel.text
    property string shortTitle: title
    property alias iconSource: iconImage.name
    property alias value: valueLabel.text

    default property alias contents: column.data

    property int maxHeight: -1

    UbuntuShape {
        id: tile

        anchors.fill: parent
        anchors.margins: units.gu(1)

        implicitHeight: titleItem.height + contents.height

        color: Qt.rgba(0,0,0,0.045) // 0.2

        radius: "medium"
        Item {
            id: titleItem
            clip: true
            height: titleLabel.height + units.gu(2.5)
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            UbuntuShape {
                radius: "medium"
                color: Qt.rgba(0,0,0,0.55) //0.2
                height: tile.height

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                AwesomeIcon {
                    id: iconImage
                    anchors {
                        left: parent.left
                        verticalCenter: titleLabel.verticalCenter
                        verticalCenterOffset: units.gu(0.1)
                        leftMargin: units.gu(2)
                    }

                    size: units.gu(3)
                    color: titleLabel.color
                }

                Label {
                    id: titleLabel

                    fontSize: "large"
                    elide: Text.ElideRight
                    color: colors["white"]

                    anchors {
                        left: iconSource === "" ? parent.left : iconImage.right
                        right: valueLabel.left
                        top: parent.top
                        margins: units.gu(2)
                        topMargin:(titleItem.height - height)/2
                    }
                }

                Label {
                    id: valueLabel

                    //fontSize: "large"

                    color: colors["white"]

                    anchors {
                        right: parent.right
                        verticalCenter: titleLabel.verticalCenter
                        margins: units.gu(2)
                    }
                }
            }
        }

        Column {
            id: contents

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Rectangle {
                width: parent.width
                height: units.dp(1)

                color: UbuntuColors.orange
            }

            Flickable {
                width: parent.width
                height: maxHeight === -1 ? column.height : Math.min(maxHeight - titleItem.height - tile.anchors.margins, column.height)

                clip: true
                contentWidth: parent.width
                contentHeight: column.height
                interactive: maxHeight !== -1

                Column {
                    id: column
                    width: parent.width
                }
            }
        }
    }
}
