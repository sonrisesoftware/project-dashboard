import QtQuick 2.0
import "../model"

import "github"

PluginView {
    id: githubPlugin

    type: "GitHub"
    title: i18n.tr("GitHub")
    icon: "github"

    property var user: service.user

    service: GitHub {
        _db: storage
    }

    items: [
        PluginItem {
            id: issuesItem

            title: i18n.tr("Issues")
            icon: "bug"

            pulseItem: IssuesPulseItem {}

            page: PlannerView {}

//            action: Action {
//                text: i18n.tr("Add Note")
//                description: i18n.tr("Add a new note to your project")
//                iconSource: getIcon("add")
//                onTriggered: pageStack.push(Qt.resolvedUrl("notes/NewNotePage.qml"), {plugin: value})
//            }
        }

    ]

    function addGitHubProject(name) {
        app.prompt(i18n.tr("Add GitHub Project"),
                   i18n.tr("Enter the name for your project connected to %1:").arg(name),
                   i18n.tr("Project Name"),
                   name).done(function (name) {
                       var project = backend.addProject(name)
                       project.addPlugin('GitHub', {name: name})
                       pageStack.push(Qt.resolvedUrl("../ui/project_page/ProjectPage.qml"), {project: project})
                       app.toast(i18n.tr("Project created"))
                   })
    }

    function createProject() {
        pageStack.push(Qt.resolvedUrl("../ui/AddGitHubProjectPage.qml"))
    }
}
