import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 0.1
import "../../backend"
import "../../backend/services"
import "../../ubuntu-ui-extras"
import "../../ubuntu-ui-extras/listutils.js" as List

// See more details @ http://qt-project.org/doc/qt-5.0/qtquick/qml-testcase.html

// Execute tests with:
//   qmltestrunner

Item {
    id: mainView

    // The objects
    Backend {
        id: backend
    }

    Database {
        id: db

        onLoaded: {
            settings.fromJSON(db.get("settings", {}))
            backend.fromJSON(db.get("backend", {}))
        }

        onSave: {
            print("Saving...")
            db.set("backend", backend.toJSON())
            db.set("settings", settings.toJSON())
        }
    }

    Document {
        id: settings

        onSave: {
            settings.set("markdownCache", markdownCache)
        }
    }

    GitHub {
        id: github
    }

    TravisCI {
        id: travisCI
    }

    function newObject(type, args) {
        var component = Qt.createComponent(type);
        return component.createObject(mainView, args);
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
            settings.set("name", "value")
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

            var project = backend.newProject(expected)
            compare(backend.projects.count,orig_length+1, "Project was not created correctly")
            compare(project.name,expected, "Project name is incorrect")

            var json = project.toJSON()
            compare(json.name,expected, "Project name is incorrect using a Document")

            project.name = new_value
            compare(project.name,new_value, "Project name is incorrect after renaming it via the Document")

            json = project.toJSON()
            compare(json.name,new_value, "Project name is incorrect using a Document")
        }

        function test_deleteProject() {
            var expected = "Sample Project";
            var second = "Second Project"

            var orig_length = backend.projects.count

            var project1 = backend.newProject(expected)
            compare(backend.projects.count,orig_length + 1, "Project was not created correctly")

            var project2 = backend.newProject(second)
            compare(backend.projects.count,orig_length + 2, "Project was not created correctly")

            project1.remove()

            compare(backend.projects.count,orig_length + 1, "Project was not deleted correctly")
            compare(backend.toJSON().projects.length, orig_length + 1, "Project still shows when saved")

            compare(project2.name,second, "Project name is incorrect after removing the other project")
        }

        function test_dbSave() {
            var orig_length = backend.projects.count

            var docId1 = backend.newProject("Dummy project")
            compare(backend.projects.count,orig_length + 1, "Project was not created correctly")
            compare(backend.toJSON().projects.length, orig_length + 1, "Project doesn't show when saved")
        }

        function test_plugins() {
            var orig_length = backend.projects.count

            var project = backend.newProject("Project name")

            var plugins = ["Notes", "Resources", "Timer", "Events"]

            plugins.forEach(function(plugin) {
                compare(project.plugins.count, 0, "There should be no plugins initially")

                project.enablePlugin(plugin, true)
                compare(project.plugins.count, 1, "The plugin isn't showing")
                compare(backend.toJSON().projects[orig_length].plugins.length, 1, "Plugin doesn't show when saved")

                project.enablePlugin(plugin, false)
                compare(project.plugins.count, 0, "There should be no plugins now")
            })
        }
    }
}
