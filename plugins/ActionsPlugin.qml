import QtQuick 2.0
import Ubuntu.Components 1.1
import "actions"

PluginView {
    title: i18n.tr("Actions")
    icon: "paper-plane"
    type: "Actions"

    items: PluginItem {
        title: i18n.tr("Actions")
        icon: "paper-plane"

        pulseItem: ActionsPulseItem {}

        action: Action {
            text: i18n.tr("Add Action")
            description: i18n.tr("Add an action that you can trigger from a button")
            iconName: "paper-plane"
            onTriggered: value.addAction("Test", "url:http://example.com")
        }
    }
}
