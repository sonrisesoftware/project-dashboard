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
import Ubuntu.Components.Pickers 0.1 as Picker
import "../backend"
import "../components"
import "../ubuntu-ui-extras"
import "../ubuntu-ui-extras/dateutils.js" as DateUtils
import "../ubuntu-ui-extras/listutils.js" as List

Plugin {
    id: plugin

    name: "appstore"
    configuration: appId ? appId : "Not connected to an app"

    title: "App Store"
    icon: "shopping-cart"

    ListModel {
        id: reviews
    }

    property string path: "https://reviews.ubuntu.com/click/api/1.0/reviews/?package_name=" + appId

    property string appId: doc.get("appId", "")

    onSave: {
        var list = []
        for (var i = 0; i < reviews.count; i++) {
            var review = reviews.get(i).modelData
            list.push(review)
        }

        doc.set("reviews", list)
    }

    onLoaded: {
        var list = doc.get("reviews", [])
        for (var i = 0; i < list.length; i++) {
            var review = list[i]
            reviews.append({"modelData": review})
        }

        refresh()
    }

    property string rating: {
        if (reviews.count == 0)
            return "Not yet rated"

        var rating = List.sum(reviews, "rating")
        rating = Math.round(rating * 2/reviews.count, 0)/2 // Multiply by two before rounding to handle 0.5 reviews

        return ratingString(rating)
    }

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

    property int syncId: -1

    function refresh() {
        if (syncId !== -1 && project.syncQueue.groups.hasOwnProperty(syncId)) {
            //print("Deleting existing sync operation for ClickAppStore")
            delete project.syncQueue.groups[syncId]
            project.syncQueue.groups = project.syncQueue.groups
        }

        syncId = project.syncQueue.newGroup(i18n.tr("Updating App Store reviews"))

        // httpGet(id, path, options, headers, callback, args)
        project.syncQueue.httpGet(syncId, path, [], undefined, function(status, response) {
            var json = JSON.parse(response)

            for (var i = 0; i < json.length; i++) {
                var found = false
                for (var j = 0; j < reviews.count; j++) {
                    var review = reviews.get(j).modelData

                    if (review.id === json[i].id) {
                        reviews.set(j, {modelData: json[i]})
                        found = true
                        break
                    }
                }

                if (!found) {
                    var r = json[i]
                    reviews.append({"modelData": r})

                    if (!doc.get("firstrun", true))
                        project.newMessage("appstore", "star-half-o", i18n.tr("New review by <b>%1</b>").arg(r.reviewer_displayname),
                                           ratingString(r.rating, true), r.date_created,
                                           {"type": "review", "id": r.id})
                }
            }

            doc.set("firstrun", false)
        })
    }

    function displayMessage(message) {
        for (var i = 0; i < reviews.count;i++) {
            var review = reviews.get(i).modelData
            if (review.id == message.data.id) {
                PopupUtils.open(reviewSheet, undefined, {review: review})
                return
            }
        }

        throw "Unable to display message: " + JSON.stringify(message)
    }

    function setup() {
        PopupUtils.open(setupSheet, mainView)
    }

    items: PluginItem {
        id: pluginItem
        title: i18n.tr("Reviews")
        icon: "star-half-o"
        value: "<font face=\"FontAwesome\">" + rating + "</font>"

        page: PluginPage {
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
                                text: i18n.tr("<b>%1</b> reviews").arg(reviews.count)

                                Label {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    font.family: "FontAwesome"
                                    text: rating
                                }
                                showDivider: false
                            }
                        }

                        Repeater {
                            model: reviews
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

        pulseItem: PulseItem {
            title: i18n.tr("Recent Reviews")
            viewAll: i18n.tr("View all <b>%1</b> reviews").arg(reviews.count)

            Repeater {
                model: Math.min(reviews.count, project.maxRecent)
                delegate: ListItem.Subtitled {
                    property var modelData: reviews.get(index).modelData

                    text: modelData.reviewer_displayname
                    subText: new Date(modelData.date_created).toDateString()
                    Label {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: "FontAwesome"
                        text: ratingString(modelData.rating)
                    }

                    onClicked: PopupUtils.open(reviewSheet, null, {review: modelData})
                }
            }
        }
    }

    Component {
        id: reviewSheet

        DefaultSheet {
            id: sheet
            title: "App Review"

            property var review

            Component.onCompleted: {
                sheet.__leftButton.text = i18n.tr("Close")
                sheet.__leftButton.color = "gray"
                sheet.__foreground.style = Theme.createStyleComponent(Qt.resolvedUrl("../ubuntu-ui-extras/SuruSheetStyle.qml"), sheet)
            }

            Label {
                id: title
                text: review.reviewer_displayname
                fontSize: "large"
            }

            Label {
                anchors.right: parent.right
                font.family: "FontAwesome"
                fontSize: "large"
                text: ratingString(review.rating)
            }

            TextArea {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: title.bottom
                    topMargin: units.gu(1)
                    bottom: parent.bottom
                }
                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText

                readOnly: true
                text: review.review_text
            }
        }
    }

    Component {
        id: setupSheet

        InputDialog {
            title: "Select App"
            text: "Enter the AppId of the app you want to display reviews for:"

            onAccepted: {
                plugin.doc.set("appId", value)
                plugin.refresh()
            }

            onRejected: {
                project.removePlugin(plugin.type)
            }
        }
    }
}
