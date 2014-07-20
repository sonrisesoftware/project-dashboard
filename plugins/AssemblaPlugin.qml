import QtQuick 2.0
import "../ui/project_page"
import "."
import "../model"
import "github"
import Ubuntu.Components 1.1

PluginView {
    id: assemblaPlugin

    type: "Assembla"
    title: i18n.tr("Assembla")
    icon: "adn"
    genericIcon: "code"
    genericTitle: i18n.tr("Code")

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
                showAllAssignedIssues: true
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

    configView: PluginConfigView {
        hasSettings: true

        Column {
            anchors.fill: parent
            anchors.margins: units.gu(2)
            spacing: units.gu(1)
            Label {
                text: "Component function (JavaScript):"
            }

            TextArea {
                width: parent.width
                height: units.gu(20)

                text: plugin.componentFunction
                onTextChanged: plugin.componentFunction = text

                color: focus ? Theme.palette.normal.overlayText : Theme.palette.normal.baseText
            }
        }
    }

    function createProject() {
    }
}
