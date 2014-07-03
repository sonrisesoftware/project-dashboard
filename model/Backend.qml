import QtQuick 2.0
import "internal" as Internal

Internal.Backend {
    id: backend

    function addProject(name) {
        var project = _db.create('Project', {name: name}, backend)
        projects.add(project)

        return project
    }

    function importProject(json) {
        var project = addProject(json.name)
    }

    /*!
     * Render markdown using the GitHub markdown API
     */
    function renderMarkdown(text, context) {
        if (typeof(text) != "string") {
            return ""
        } if (settings.markdownCache.hasOwnProperty(text)) {
            /// Custom color for links
            var response = colorLinks(settings.markdownCache[text])
            return response
        } else {
            //print("Calling Markdown API")
            Http.post(github.github + "/markdown", ["access_token=" + github.oauth], function(has_error, status, response) {
                settings.markdownCache[text] = response
                settings.markdownCache = settings.markdownCache
            }, undefined, undefined, JSON.stringify({
                "text": text,
                "mode": context !== undefined ? "gfm" : "markdown",
                "context": context
              }))
            return "Loading..."
        }
    }

    property var availablePlugins

    function getPlugin(name) {
        for (var i = 0; i < availablePlugins.count;i++) {
            var plugin = availablePlugins.get(i)
            if (plugin.name === name)
                return plugin
        }
    }

    function clearInbox() {
        for (var i = 0; i < projects.count; i++) {
            var project = projects.get(i).modelData
            project.clearInbox()
        }
    }
}
