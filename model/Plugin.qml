import QtQuick 2.0
import "internal" as Internal
import "../ui/project_page"

Internal.Plugin {
    property string configuration: ""

    property string title
    property string icon

    /*!
     * Called when the plugin is first added to a project
     */
    function setup() {}

    property Component configView: PluginConfigView {

    }

    function displayMessage(message) {}

    function getPreview(message) {}

    property list<PluginItem> items
}
