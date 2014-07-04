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

    show: List.length(reviews) > 0
    title: i18n.tr("Recent Reviews")

    viewAll: plugin ? i18n.tr("View all <b>%1</b> reviews").arg(List.length(reviews)) : ""

    property var reviews: {
        if (plugin) {
            return plugin.reviews
        } else {
            var reviews = []

            for (var i = 0; i < backend.projects.count; i++) {
                var project = backend.projects.at(i)
                var p = project.getPlugin('ClickStore')

                if (p) {
                    for (var j = 0; j < p.reviews.length; j++) {
                        var review = p.reviews[j]
                        review = JSON.parse(JSON.stringify(review))
                        review.project = project
                        reviews.push(review)
                    }
                }
            }

            return reviews
        }
    }

    ListItem.Standard {
        text: i18n.tr("No reviews")
        enabled: false
        visible: List.length(reviews) === 0
        height: visible ? implicitHeight : 0
    }

    Repeater {
        model: Math.min(reviews.length, 3)
        delegate: SubtitledListItem {
            property var modelData: reviews[index]

            text: modelData.reviewer_displayname
            subText: plugin ? new Date(modelData.date_created).toDateString() : modelData.project.name
            Label {
                anchors.right: parent.right
                anchors.rightMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                font.family: "FontAwesome"
                text: ratingString(modelData.rating)
            }

            onClicked: pageStack.push(Qt.resolvedUrl("ReviewPage.qml"), {review: modelData, plugin: plugin})
        }
    }
}
