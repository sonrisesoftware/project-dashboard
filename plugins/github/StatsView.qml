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

import "../../components"
import "../../backend"
import "../../ubuntu-ui-extras/listutils.js" as List
import "../../ubuntu-ui-extras"

PluginItem {
    id: statsView

    title: i18n.tr("Statistics")
    icon: "bar-chart-o"

    page: PluginPage {
        title: i18n.tr("Statistics")

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
                        title: i18n.tr("Commits")

                        ListItem.Header {
                            text: i18n.tr("This Past Week")
                        }

                        ListItem.SingleValue {
                            text: i18n.tr("All team members")
                        }

                        Repeater {
                            model: plugin.commitStats
                            delegate: ListItem.SingleValue {
                                text: modelData.login
                            }
                        }
                    }

                }
            }
        }
    }
}
