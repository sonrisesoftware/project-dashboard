import QtQuick 2.0

QtObject {
    property string email
    property int size: -1

    property url url: {
        var str = email.trim().toLowerCase()
        var hash = Qt.md5(str)
        var url = "http://www.gravatar.com/avatar/" + hash + ".jpg"
        if (size > 0) {
            url += "?s=" + size
        }

        return url
    }
}
