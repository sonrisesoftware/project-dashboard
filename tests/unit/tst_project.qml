import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 0.1
import "../../backend"
import "../../ubuntu-ui-extras"

// See more details @ http://qt-project.org/doc/qt-5.0/qtquick/qml-testcase.html

// Execute tests with:
//   qmltestrunner

Item {
    // The objects
    Backend {
        id: backend
    }

    Database {
        id: db
    }

    TestCase {
        name: "HelloComponent"

        function init() {
            console.debug(">> init");
            compare(backend.projects.length,0,"No projects should exist beforehand");
            console.debug("<< init");
        }

        function cleanup() {
            console.debug(">> cleanup");
            console.debug("<< cleanup");
        }

        function initTestCase() {
            console.debug(">> initTestCase");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_createProject() {
            var expected = "Hello World";

            backend.newProject(expected)
            compare(backend.projects.length,1, "Project was not created correctly")
        }
    }
}
