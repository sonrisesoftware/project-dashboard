import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../model"

Column {
    id: column

    width: parent.width
    height: childrenRect.height

    property string title
    property string viewAll
    property bool show: title !== ""
    property bool showAnyway: wideAspect && title !== ""
    property bool showFooter: plugin !== null

    property int maxItems: Math.max(3, maxPulseItems)

    states: State {
        when: !(show || showAnyway)

        PropertyChanges {
            target: column
            restoreEntryValues: true
            height: 0
            opacity: 0
        }
    }

    transitions: Transition {
        from: "*"
        to: "*"

        UbuntuNumberAnimation {
            target: column
            properties: "height,opacity"
        }
    }
}
