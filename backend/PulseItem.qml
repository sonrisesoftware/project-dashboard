import QtQuick 2.0
import Ubuntu.Components.ListItems 0.1 as ListItem

Column {
    id: column

    width: parent.width

    property string title

    ListItem.Header {
        text: title
    }
}
