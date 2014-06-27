import QtQuick 2.0
import "../../udata"
import ".."

Document {
    id: object

    _type: "Message"

    property string icon
    onIconChanged: _set("icon", icon)

    property string title
    onTitleChanged: _set("title", title)

    onLoaded: {
        icon = _get("icon", "")
        title = _get("title", "")
    }
}
