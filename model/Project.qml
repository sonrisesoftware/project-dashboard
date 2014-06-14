import QtQuick 2.0
import "internal" as Internal

Internal.Project {
    id: project

    function hasPlugin(type) {
        return getPlugin(type) !== null
    }

    function getPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.get(i)
            if (plugin._type === type + "Plugin")
                return plugin
        }

        return null
    }

    function addPlugin(type) {
        if (hasPlugin(type))
            throw "Plugin already added"

        var plugin = _db.create(type + "Plugin", {project: project}, project)
        plugins.add(plugin)

        return plugin
    }
}
