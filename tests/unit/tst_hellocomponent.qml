import QtQuick 2.0
import QtTest 1.0
import Ubuntu.Components 0.1
import "../../components"

// See more details @ http://qt-project.org/doc/qt-5.0/qtquick/qml-testcase.html

// Execute tests with:
//   qmltestrunner

Item {
    // The objects
    HelloComponent {
        id: objectUnderTest
    }

    TestCase {
        name: "HelloComponent"

        function init() {
            console.debug(">> init");
            compare("",objectUnderTest.text,"text was not empty on init");
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

        function test_canReadAndWriteText() {
            var expected = "Hello World";

            objectUnderTest.text = expected;

            compare(expected,objectUnderTest.text,"expected did not equal result");
        }
    }
}
