import QtQuick 2.0
import "internal" as Internal

Internal.ActionItem {
    property string summary: {
        if (action.indexOf("url:") == 0) {
            return action.substring(4)
        } else {
            return ""
        }
    }

    function trigger() {
        click_count += 1
    }
}
