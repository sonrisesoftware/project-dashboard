import QtQuick 2.0
import "../model"

import "github"

PluginView {
    id: githubPlugin

    type: "GitHub"
    title: i18n.tr("GitHub")
    icon: "github"

    service: GitHub {
        _db: storage
    }

    items: [
        PluginItem {
            id: issuesItem

            title: i18n.tr("Issues")

            pulseItem: IssuesPulseItem {}

            //page: IssuesPage {}

//            action: Action {
//                text: i18n.tr("Add Note")
//                description: i18n.tr("Add a new note to your project")
//                iconSource: getIcon("add")
//                onTriggered: pageStack.push(Qt.resolvedUrl("notes/NewNotePage.qml"), {plugin: value})
//            }
        }

    ]
}
