import QtQuick 2.0
import "internal" as Internal

Internal.Project {

    function getPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.at(i)
            if (plugin._type === type)
                return plugin
        }

        return null
    }

    function hasPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.at(i)
            if (plugin._type === type)
                return true
        }

        return false
    }
}
