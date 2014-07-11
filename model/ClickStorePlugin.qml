import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/httplib.js" as Http
import "../qml-extras/listutils.js" as List

Internal.ClickStorePlugin {
    pluginView: clickPlugin

    property string path: "https://reviews.ubuntu.com/click/api/1.0/reviews/?package_name=" + appId

    onPathChanged: if (appId) refresh()

    function refresh() {
        Http.get(path).done(function(response) {
            var json = JSON.parse(response)

            if (!reviews)
                reviews = []

            for (var i = 0; i < json.length; i++) {
                var found = false
                for (var j = 0; j < reviews.length; j++) {
                    var review = reviews[j]

                    if (review.id === json[i].id) {
                        reviews[i] = json[i]
                        found = true
                        break
                    }
                }

                if (!found) {
                    var r = json[i]
                    reviews.push(r)

//                    if (!doc.get("firstrun", true))
//                        project.newMessage("appstore", "star-half-o", i18n.tr("New review by <b>%1</b>").arg(r.reviewer_displayname),
//                                           ratingString(r.rating, true), r.date_created,
//                                           {"type": "review", "id": r.id})
                }
            }

            reviews = reviews
        })
    }

    function setup() {
        app.prompt(i18n.tr("Ubuntu Click Store"), i18n.tr("Enter the AppId of the app in the Ubuntu Store:"), "com.domain.app", "").done(function (name) {
            appId = name
        })
    }

    property string rating: {
        if (reviews.length === 0)
            return "Not yet rated"

        var rating = List.sum(reviews, "rating")
        rating = Math.round(rating * 2/reviews.length, 0)/2 // Multiply by two before rounding to handle 0.5 reviews

        return clickPlugin.ratingString(rating)
    }
}
