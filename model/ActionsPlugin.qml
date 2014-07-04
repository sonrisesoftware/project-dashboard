import QtQuick 2.0
import "internal" as Internal

Internal.ActionsPlugin {
    id: plugin
    pluginView: actionsPlugin

    function addAction(text, action) {
        var obj = _db.create('ActionItem', {text: text, action: action}, plugin)
        actions.add(obj)
    }
}
