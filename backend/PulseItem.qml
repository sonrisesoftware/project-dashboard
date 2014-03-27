import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Column {
    id: column

    width: parent.width

    property string title
    property string viewAll
    property bool show: title !== ""

    height: opacity === 0 ? 0 : implicitHeight

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    opacity: show ? 1 : 0

    Behavior on opacity {
        UbuntuNumberAnimation {}
    }

    ListItem.Header {
        text: title
    }
}
