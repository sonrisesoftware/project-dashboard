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
        Component.onCompleted: db.document.loaded = true
    }

    Document {
        id: settings
        docId: "settings"
        parent: db.document
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
            compare(backend.projects.length,0,"No projects should exist beforehand");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_createProject() {
            var expected = "Sample Project";
            var new_value = "Renamed Project"

            var docId = backend.newProject(expected)
            compare(backend.projects.length,1, "Project was not created correctly")

            var project = newObject(Qt.resolvedUrl("../../backend/Project.qml"), {docId: docId})
            compare(project.name,expected, "Project name is incorrect")

            var document = newObject(Qt.resolvedUrl("../../ubuntu-ui-extras/Document.qml"), {docId: docId, parent: backend.document})
            compare(document.get("name"),expected, "Project name is incorrect using a Document")

            document.set("name", new_value)
            compare(project.name,new_value, "Project name is incorrect after renaming it via the Document")

            project.name = expected
            compare(document.get("name"),expected, "Project name is incorrect using a Document")
        }

        function test_deleteProject() {
            var expected = "Sample Project";
            var second = "Second Project"

            var orig_length = backend.projects.length

            var docId1 = backend.newProject(expected)
            compare(backend.projects.length,orig_length + 1, "Project was not created correctly")

            var docId2 = backend.newProject(second)
            compare(backend.projects.length,orig_length + 2, "Project was not created correctly")

            print(JSON.stringify(backend.document.save().children))

            var project = newObject(Qt.resolvedUrl("../../backend/Project.qml"), {docId: docId1})
            var project2 = newObject(Qt.resolvedUrl("../../backend/Project.qml"), {docId: docId2})
            project.remove()

            compare(backend.projects.length,orig_length + 1, "Project was not deleted correctly")
            compare(List.objectKeys(backend.document.save().children).length, orig_length + 1, "Project still shows when saved")

            compare(project2.name,second, "Project name is incorrect after removing the other project")
        }

        function test_dbSave() {
            var orig_length = backend.projects.length

            var docId1 = backend.newProject("Dummy project")
            compare(backend.projects.length,orig_length + 1, "Project was not created correctly")
            compare(List.objectKeys(backend.document.save().children).length, orig_length + 1, "Project doesn't show when saved")

            print(List.objectKeys(db.document.save().children))
            compare(List.objectKeys(db.document.save().children).length, 2, "Backend and settings aren't being saved")

        }
    }
}
