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
    id: root

    Document {
        id: document
        loaded: true
    }

    function newObject(type, args) {
        var component = Qt.createComponent(type);
        return component.createObject(root, args);
    }

    TestCase {
        name: "Document"

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
            compare(document.children.length,0, "No documents should exist beforehand");
            console.debug("<< initTestCase");
        }

        function cleanupTestCase() {
            console.debug(">> cleanupTestCase");
            console.debug("<< cleanupTestCase");
        }

        function test_createDocument() {
            var docId = 41
            var obj = {"number": 1, "value": "Test"}

            document.newDoc(docId, obj)

            compare(document.children.length,1, "Document was not created correctly")

            compare(document.hasChild(docId), true, "Document doesn't show up")
            compare(document.hasChild(21), false, "Document doesn't show up")

            var doc = document.getChild(docId)
            print(doc)
            compare(doc.docId, String(docId), "Document wasn't retrived correctly")
            compare(doc.parent, document, "Child's parent wasn't set correctly")
        }

        function test_filterChildren() {
            var obj1 = {"number": 1, "value": "Test"}
            var obj2 = {"number": 2, "value": "Blah"}

            document.removeChildren()
            compare(document.children.length,0, "Document was not erased")

            document.newDoc("item1", obj1)
            document.newDoc("item2", obj2)

            compare(document.children.length,2, "Documents were not created correctly")

            var list = document.filteredChildren(function (doc) { return doc.number === 1})
            compare(list.length,1, "Filter isn't working")
            compare(list[0],"item1", "Filter isn't working")
        }
    }
}
