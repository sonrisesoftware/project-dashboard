import QtQuick 2.0
import "internal" as Internal

Internal.Project {
    id: project

    property string configuration: {
        if (hasPlugin('GitHub'))
            return awesomeIcon("github") + " " + getPlugin('GitHub').name
        else if (hasPlugin('Launchpad'))
            return awesomeIcon("empire") + " lp:" + getPlugin('Launchpad').name
        else if (hasPlugin('Assembla'))
            return awesomeIcon("adn") + " " + getPlugin('Assembla').name
        else
            return ""
    }

    function getPlugin(type) {
        for (var i = 0; i < plugins.count; i++) {
            var plugin = plugins.at(i)
            if (plugin._type === type + 'Plugin' || plugin._type === type)
                return plugin
        }

        return null
    }

    function hasPlugin(type) {
        return getPlugin(type) !== null
    }

    function addPlugin(type, args) {
        if (hasPlugin(type))
            throw "Plugin already added"

        if (args) {
            args.project = project
            var plugin = _db.create(type + "Plugin", args, project)
            plugin.refresh()
            plugins.add(plugin)
        } else {
            var plugin = _db.create(type + "Plugin", {project: project}, project)
            plugin.setup()
            plugins.add(plugin)
        }

        return plugin
    }
}
