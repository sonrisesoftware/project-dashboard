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

import "../../model"
import "../../components"

Popover {
    id: actionsPopover

    property Project project

    Column {
        width: parent.width

        Item {
            width: parent.width
            height: noneLabel.height + units.gu(4)

            visible: actionsColumn.height === 0

            Label {
                id: noneLabel
                anchors.centerIn: parent

                width: parent.width - units.gu(4)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter

                text: i18n.tr("No available actions")
                color: Theme.palette.normal.overlayText
            }
        }

        Column {
            id: actionsColumn

            width: parent.width

            Repeater {
                model: project.plugins
                delegate: Repeater {
                    model: modelData.items
                    delegate: AwesomeListItem {
                        id: actionListItem
                        showDivider: actionListItem.y + actionListItem.height < actionsColumn.height
                        visible: modelData.action
                        enabled: visible ? modelData.action.enabled : false
                        onClicked: {
                            PopupUtils.close(actionsPopover)
                            modelData.action.triggered(app)
                        }

                        icon: modelData.icon

                        text: actionListItem.visible ? modelData.action.text : ""
                        subText: actionListItem.visible ? modelData.action.description : ""
                    }
                }
            }
        }
    }
}
