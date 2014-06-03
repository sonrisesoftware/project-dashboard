import QtQuick 2.0
import "internal" as Internal
import "../qml-extras/utils.js" as Utils

Internal.Settings {
    property bool firstRun

    onLoaded: {
        if (uuid === "") {
            uuid = Utils.generateID()
            firstRun = true
        } else {
            firstRun = false
        }
    }
}
