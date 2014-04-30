import QtQuick 2.0
import "../qml-air"

Item {
    property string title
    property string shortTitle: title
    property string icon
    property bool enabled: true

    property string value

    property Page page

    property Component pulseItem

    property Action action
}
