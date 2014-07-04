import QtQuick 2.0
import "../../udata"
import ".."

// Automatically generated from a uData model
Plugin {
    id: object

    _type: "ClickStorePlugin"

    property var reviews: []
    onReviewsChanged: _set("reviews", reviews)

    property string appId: ""
    onAppIdChanged: _set("appId", appId)

    onCreated: {
        _set("reviews", reviews)
        _set("appId", appId)
        _loaded = true
        _created = true
    }

    onLoaded: {
        reviews = _get("reviews")
        appId = _get("appId")
    }

    _properties: ["_type", "_version", "reviews", "appId"]
}
