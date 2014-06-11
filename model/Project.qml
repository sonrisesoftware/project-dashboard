import QtQuick 2.0
import "internal" as Internal

Internal.Project {

    function hasPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i)
            if (plugin._type === type)
                return true
        }

        return false
    }
}
