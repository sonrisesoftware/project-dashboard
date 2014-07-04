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


Page {
    id: sheet
    title: "App Review"

    property ClickStorePlugin plugin

    property var review

    Label {
        id: title
        text: review.project ? review.project.name : plugin.parent.name //review.reviewer_displayname
        anchors {
            top: parent.top
            left: parent.left
            right: rating.left
            margins: units.gu(2)
        }

        fontSize: "large"
    }

    Label {
        id: author
        text: review.reviewer_displayname
        anchors {
            top: title.bottom
            left: parent.left
            leftMargin: units.gu(2)
        }

        opacity: 0.65
    }

    Label {
        id: rating
        anchors {
            top: parent.top
            right: parent.right
            margins: units.gu(2)
        }

        font.family: "FontAwesome"
        fontSize: "large"
        text: clickPlugin.ratingString(review.rating)
    }

    Label {
        text: new Date(review.date_created).toDateString()
        opacity: 0.65
        anchors {
            top: title.bottom
            right: parent.right
            rightMargin: units.gu(2)
        }
    }

    TextArea {
        anchors {
            left: parent.left
            right: parent.right
            top: author.bottom
            margins: units.gu(2)
            bottom: parent.bottom
        }
        color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

        readOnly: true
        text: review.review_text
    }
}
