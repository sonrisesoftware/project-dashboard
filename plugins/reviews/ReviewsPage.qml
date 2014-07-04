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
import "../../components"
import "../../ubuntu-ui-extras"
import "../../model"

PluginPage {
    title: "Reviews"

    Flickable {
        id: reviewsList
        anchors.fill: parent

        contentWidth: width
        contentHeight: column.contentHeight + units.gu(2)
        clip: true

        Item {
            width: reviewsList.width
            height: column.contentHeight + units.gu(2)
            ColumnFlow {
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: units.gu(1)
                }
                repeaterCompleted: true
                columns: extraWideAspect ? 3 : wideAspect ? 2 : 1

                onVisibleChanged: {
                    column.repeaterCompleted = true
                    column.reEvalColumns()
                }

                Timer {
                    interval: 10
                    running: true
                    onTriggered: {
                        //print("Triggered!")
                        column.repeaterCompleted = true
                        column.reEvalColumns()
                    }
                }

                GridTile {
                    title: "Overall Rating"

                    ListItem.SingleValue {
                        text: i18n.tr("<b>%1</b> reviews").arg(plugin.reviews.length)

                        Label {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: "FontAwesome"
                            text: plugin.rating
                        }
                        showDivider: false
                    }
                }

                Repeater {
                    model: plugin.reviews
                    delegate: GridTile {
                        title: modelData.reviewer_displayname
                        value: ratingString(modelData.rating, true)

                        ListItem.Empty {
                            height: _desc.height + units.gu(4)
                            Label {
                                id: _desc
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    right: parent.right
                                    margins: units.gu(2)
                                }
                                text: modelData.review_text
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }

                            showDivider: false
                        }
                    }
                }
            }
        }
    }

    Scrollbar {
        flickableItem: reviewsList
    }
}
