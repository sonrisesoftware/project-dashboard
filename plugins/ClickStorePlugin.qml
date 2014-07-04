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
import "reviews"
import "../ui"
import "../components"
import "../ubuntu-ui-extras"
import "../model"
import "."

PluginView {
    id: clickPlugin

    type: "ClickStore"
    title: i18n.tr("Click App Store")
    shortTitle: i18n.tr("Store")
    icon: "shopping-cart"

    items: [
        PluginItem {
            title: i18n.tr("Reviews")
            icon: "star-half-o"
            pulseItem: ReviewsPulseItem {}

            page: ReviewsPage {}
        }
    ]

    function ratingString(rating, font) {
        var string = ""
        while (rating >= 1) {
            string += " " // star
            rating--
        }

        if (rating === 0.5) {
            string += " " // star-half-o
        }

        // Each star takes two spaces
        while (string.length < 5 * 2) {
            string += " " // star-o
        }

        if (font)
            return '<font face="FontAwesome">%1</font>'.arg(string.substring(1))
        else
            return string.substring(1)
    }
}
