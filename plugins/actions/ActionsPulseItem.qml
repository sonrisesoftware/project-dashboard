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
import "../../qml-extras/listutils.js" as List
import "../../ubuntu-ui-extras"
import "../../model"
import "../../qml-extras/utils.js" as Utils

PulseItem {
    id: pulseItem

    show: List.length(actions) > 0
    title: i18n.tr("Favorite Actions")

    viewAll: plugin ? i18n.tr("View all <b>%1</b> actions").arg(List.length(actions)) : ""

    property var actions: {
        if (plugin) {
            return plugin.actions
        } else {
            var actions = []

            for (var i = 0; i < backend.projects.count; i++) {
                var project = backend.projects.at(i)
                var p = project.getPlugin('Actions')

                if (p) {
                    actions = actions.concat(List.toList(p.actions))
                }
            }


            actions = actions.sort(function (a, b) {
                return b.click_count - a.click_count
            })

            return actions
        }
    }

    ListItem.Standard {
        text: i18n.tr("No actions")
        enabled: false
        visible: List.length(actions) === 0
        height: visible ? implicitHeight : 0
    }

    Repeater {
        id: repeater
        model: Math.min(List.length(actions), maxItems)
        delegate: SubtitledListItem {
            id: item

            property ActionItem action: List.getItem(actions, index)

            text: action.text
            subText: action.summary

            onClicked: action.trigger()

            removable: true
            showDivider: index < repeater.count - 1 || showFooter
            backgroundIndicator: ListItemBackground {
                state: item.swipingState
                iconSource: getIcon("delete-white")
                text: i18n.tr("Delete")
            }
            onItemRemoved: {
                action.remove()
            }
        }
    }
}
