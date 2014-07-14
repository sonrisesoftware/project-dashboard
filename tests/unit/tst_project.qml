import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 1.1
import "../../model"
import "../../udata"
import "../../ubuntu-ui-extras"
import "../../qml-extras/listutils.js" as List

// See more details @ http://qt-project.org/doc/qt-5.0/qtquick/qml-testcase.html

// Execute tests with:
//   qmltestrunner

Item {
    id: mainView

    // The objects
    Backend {
        id: backend
        _db: db
    }

    Database {
        id: db
        modelPath: Qt.resolvedUrl("../../model")
    }

    TestCase {
        name: "Project"

        function init() {
            console.debug(">> init");
            console.debug("<< init");
        }

        function cleanup() {
            console.debug(">> cleanup");
            console.debug("<< cleanup");
        }

        function initTestCase() {
            console.debug(">> initTestCase");
            compare(backend.projects.count,0,"No projects should exist beforehand");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_createProject() {
            var expected = "Sample Project";
            var new_value = "Renamed Project"

            var orig_length = backend.projects.count

            var project = backend.addProject(expected)
            compare(backend.projects.count,orig_length+1, "Project was not created correctly")
            compare(project.name,expected, "Project name is incorrect")
        }

        function test_deleteProject() {
            var expected = "Sample Project";
            var second = "Second Project"

            var orig_length = backend.projects.count

            var project1 = backend.addProject(expected)
            compare(backend.projects.count,orig_length + 1, "Project was not created correctly")

            var project2 = backend.addProject(second)
            compare(backend.projects.count,orig_length + 2, "Project was not created correctly")

            project1.remove()

            compare(backend.projects.count,orig_length + 1, "Project was not deleted correctly")

            compare(project2.name,second, "Project name is incorrect after removing the other project")
        }

        function test_saveIssue() {
            var expected = [{"author":{"avatar_url":"https://avatars.githubusercontent.com/u/3230912?","events_url":"https://api.github.com/users/iBeliever/events{/privacy}","followers_url":"https://api.github.com/users/iBeliever/followers","following_url":"https://api.github.com/users/iBeliever/following{/other_user}","gists_url":"https://api.github.com/users/iBeliever/gists{/gist_id}","gravatar_id":"02a20d65870e76a018e0b4a31d3676bb","html_url":"https://github.com/iBeliever","id":3230912,"login":"iBeliever","organizations_url":"https://api.github.com/users/iBeliever/orgs","received_events_url":"https://api.github.com/users/iBeliever/received_events","repos_url":"https://api.github.com/users/iBeliever/repos","site_admin":false,"starred_url":"https://api.github.com/users/iBeliever/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/iBeliever/subscriptions","type":"User","url":"https://api.github.com/users/iBeliever"},"comments_url":"https://api.github.com/repos/sonrisesoftware/project-dashboard/commits/af2241fca269b3f9d773929400a771709b0e216e/comments","commit":{"author":{"date":"2014-05-16T02:38:53Z","email":"sonrisesoftware@gmail.com","name":"Michael Spencer"},"comment_count":0,"committer":{"date":"2014-05-16T02:38:53Z","email":"sonrisesoftware@gmail.com","name":"Michael Spencer"},"message":"Initial work on a sidebar","tree":{"sha":"6cec0c8050b88848d67eb349cde132a5904dda6b","url":"https://api.github.com/repos/sonrisesoftware/project-dashboard/git/trees/6cec0c8050b88848d67eb349cde132a5904dda6b"},"url":"https://api.github.com/repos/sonrisesoftware/project-dashboard/git/commits/af2241fca269b3f9d773929400a771709b0e216e"},"committer":{"avatar_url":"https://avatars.githubusercontent.com/u/3230912?","events_url":"https://api.github.com/users/iBeliever/events{/privacy}","followers_url":"https://api.github.com/users/iBeliever/followers","following_url":"https://api.github.com/users/iBeliever/following{/other_user}","gists_url":"https://api.github.com/users/iBeliever/gists{/gist_id}","gravatar_id":"02a20d65870e76a018e0b4a31d3676bb","html_url":"https://github.com/iBeliever","id":3230912,"login":"iBeliever","organizations_url":"https://api.github.com/users/iBeliever/orgs","received_events_url":"https://api.github.com/users/iBeliever/received_events","repos_url":"https://api.github.com/users/iBeliever/repos","site_admin":false,"starred_url":"https://api.github.com/users/iBeliever/starred{/owner}{/repo}","subscriptions_url":"https://api.github.com/users/iBeliever/subscriptions","type":"User","url":"https://api.github.com/users/iBeliever"},"html_url":"https://github.com/sonrisesoftware/project-dashboard/commit/af2241fca269b3f9d773929400a771709b0e216e","parents":[{"html_url":"https://github.com/sonrisesoftware/project-dashboard/commit/c437aac66b83ed0f85ff61b286cca14f99685f39","sha":"c437aac66b83ed0f85ff61b286cca14f99685f39","url":"https://api.github.com/repos/sonrisesoftware/project-dashboard/commits/c437aac66b83ed0f85ff61b286cca14f99685f39"}],"sha":"af2241fca269b3f9d773929400a771709b0e216e","url":"https://api.github.com/repos/sonrisesoftware/project-dashboard/commits/af2241fca269b3f9d773929400a771709b0e216e"}]

            var issue = db.create('Issue', {}, backend)
            issue.commits = expected
            var data = issue._contents
            print(JSON.stringify(data))
            issue.destroy()

            var loaded = db.load(data, backend)

            compare(JSON.stringify(loaded.commits), JSON.stringify(expected))
        }

//        function test_dbSave() {
//            var orig_length = backend.projects.count

//            var docId1 = backend.addProject("Dummy project")
//            compare(backend.projects.count,orig_length + 1, "Project was not created correctly")
//            //compare(backend.toJSON().projects.length, orig_length + 1, "Project doesn't show when saved")
//        }

//        function test_plugins() {
//            var orig_length = backend.projects.count

//            var project = backend.addProject("Project name")

//            var plugins = ["Notes", "Events"]

//            plugins.forEach(function(plugin) {
//                compare(project.plugins.count, 0, "There should be no plugins initially")

//                project.enablePlugin(plugin, true)
//                compare(project.plugins.count, 1, "The plugin isn't showing")
//                compare(backend.toJSON().projects[orig_length].plugins.length, 1, "Plugin doesn't show when saved")

//                project.enablePlugin(plugin, false)
//                compare(project.plugins.count, 0, "There should be no plugins now")
//            })
//        }
    }
}
