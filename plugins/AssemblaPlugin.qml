import QtQuick 2.0
import "../model"

import "github"

PluginView {
    id: assemblaPlugin

    type: "Assembla"
    title: i18n.tr("Assembla")
    icon: "adn"

    property var user: service.user

    service: Assembla {
        _db: storage
    }

    items: [
        PluginItem {
            id: issuesItem

            title: i18n.tr("Tickets")
            icon: "bug"

            pulseItem: IssuesPulseItem {
                title: i18n.tr("Assigned Tickets")
                type: "tickets"
                pluginType: "Assembla"
            }

            page: PlannerView {}

//            action: Action {
//                text: i18n.tr("Add Note")
//                description: i18n.tr("Add a new note to your project")
//                iconSource: getIcon("add")
//                onTriggered: pageStack.push(Qt.resolvedUrl("notes/NewNotePage.qml"), {plugin: value})
//            }
        }

    ]

    function createProject() {
    }
}
